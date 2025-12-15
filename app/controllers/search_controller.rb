# frozen_string_literal: true

class SearchController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      # Search resources (respecting admin_only visibility)
      resources = Resource.visible_to(current_user)
        .where("name ILIKE ?", "%#{@query}%")
        .includes(:resource_locations, :resource_external_locations)
        .order(:name)

      @internal_resources = resources.internal
      @external_resources = resources.external

      # Search maps
      @maps = Map.where("name ILIKE ?", "%#{@query}%")
        .includes(:parent, image_attachment: :blob)
        .order(:name)
    else
      @internal_resources = Resource.none
      @external_resources = Resource.none
      @maps = Map.none
    end

    @total_count = @internal_resources.count + @external_resources.count + @maps.count
  end
end

