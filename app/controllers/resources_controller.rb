# frozen_string_literal: true

class ResourcesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :feed]
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :check_admin_only_access, only: [:show]
  before_action :set_journable_user, only: [:create, :update, :destroy]

  def index
    @sort_column = params[:sort].presence_in(["name", "views", "updated", "type", "locations"]) || "name"
    @sort_direction = params[:direction].presence_in(["asc", "desc"]) || "asc"

    all_resources = Resource.visible_to(current_user).includes(:parent, :children, :resource_urls,
                                                               resource_locations: :map)

    # If sorting by name, use hierarchical grouping; otherwise flat sorted list
    if @sort_column == "name" && @sort_direction == "asc"
      @resources = build_hierarchical_list(all_resources)
      @internal_resources = build_hierarchical_list(all_resources.internal)
      @external_resources = build_hierarchical_list(all_resources.external)
    else
      @resources = sort_resources(all_resources)
      @internal_resources = sort_resources(all_resources.internal)
      @external_resources = sort_resources(all_resources.external)
    end
  end

  def feed
    @resources = Resource.public_only
      .includes(:parent, :resource_urls, resource_locations: :map, resource_external_locations: [])
      .order(created_at: :desc)
      .limit(30)
    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  def show
    @resource.increment!(:view_count)
  end

  def new
    @resource = Resource.new
    @resource.resource_urls.build
    # Don't build a location - user can add multiple via "Add Location" button
  end

  def edit
    @resource.resource_urls.build if @resource.resource_urls.empty?
  end

  def create
    @resource = Resource.new(resource_params)

    if @resource.save
      redirect_to @resource, notice: "Resource was successfully created."
    else
      @resource.resource_urls.build if @resource.resource_urls.empty?
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @resource.update(resource_params)
      redirect_to @resource, notice: "Resource was successfully updated."
    else
      @resource.resource_urls.build if @resource.resource_urls.empty?
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @resource.destroy
    redirect_to resources_path, notice: "Resource was successfully deleted."
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def check_admin_only_access
    return unless @resource.admin_only? && !current_user&.admin?

    redirect_to resources_path, alert: "You don't have access to that resource."
  end

  def resource_params
    permitted = [:name, :description, :internal, :parent_id, :icon,
                 { resource_urls_attributes: [:id, :url, :label, :_destroy],
                   resource_locations_attributes: [:id, :map_id, :x, :y, :_destroy],
                   resource_external_locations_attributes: [:id, :latitude, :longitude, :url, :label, :address, :_destroy] }]

    # Only admins can set admin_only flag
    permitted << :admin_only if current_user&.admin?

    params.require(:resource).permit(*permitted)
  end

  def set_journable_user
    Resource.current_user = current_user
  end

  def build_hierarchical_list(resources)
    # Get top-level resources (no parent, or parent not in this list)
    resource_ids = resources.pluck(:id)
    top_level = resources.select { |r| r.parent_id.nil? || resource_ids.exclude?(r.parent_id) }

    result = []
    top_level.sort_by(&:name).each do |parent|
      result << parent
      # Add children sorted alphabetically
      children = resources.select { |r| r.parent_id == parent.id }.sort_by(&:name)
      result.concat(children)
    end

    result
  end

  def sort_resources(resources)
    sorted = case @sort_column
             when "views"
               resources.sort_by(&:view_count)
             when "updated"
               resources.sort_by(&:updated_at)
             when "type"
               resources.sort_by { |r| r.internal? ? 0 : 1 }
             when "locations"
               resources.sort_by do |r|
                 r.internal? ? r.resource_locations.count : r.resource_external_locations.count
               end
             else # "name" or any other value
               resources.sort_by { |r| r.name.downcase }
             end

    @sort_direction == "desc" ? sorted.reverse : sorted
  end
end
