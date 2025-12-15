class MapsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :image_url]
  before_action :set_map, only: [:show, :edit, :update, :destroy]
  before_action :authorize_edit!, only: [:edit, :update, :destroy]
  before_action :set_journable_user, only: [:create, :update, :destroy]

  def index
    @maps = Map.includes(:parent, :maintainers, image_attachment: :blob).all
    @root_maps = @maps.where(parent: nil)
  end

  def show
  end

  def new
    @map = Map.new
    @map.parent_id = params[:parent_id] if params[:parent_id]
  end

  def create
    @map = Map.new(map_params)

    if @map.save
      redirect_to @map, notice: "Map was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @map.update(map_params)
      redirect_to @map, notice: "Map was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @map.destroy
    redirect_to maps_path, notice: "Map was successfully deleted."
  end

  def image_url
    @map = Map.find(params[:id])
    if @map.image.attached?
      render json: { url: url_for(@map.image), name: @map.name }
    else
      render json: { url: nil, name: @map.name }
    end
  end

  private

  def set_map
    @map = Map.find(params[:id])
  end

  def authorize_edit!
    unless @map.can_edit?(current_user)
      redirect_to @map, alert: "You are not authorized to edit this map."
    end
  end

  def map_params
    params.require(:map).permit(:name, :slack_channel, :parent_id, :image, :is_default, maintainer_ids: [])
  end

  def set_journable_user
    Map.current_user = current_user
  end
end

