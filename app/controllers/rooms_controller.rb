# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :require_admin
  before_action :set_map
  before_action :set_room, only: [:show, :edit, :update, :destroy]

  def index
    @rooms = @map.rooms.order(:name)
  end

  def show
  end

  def new
    @room = @map.rooms.build
  end

  def edit
  end

  def create
    @room = @map.rooms.build(room_params)

    if @room.save
      respond_to do |format|
        format.html { redirect_to map_rooms_path(@map), notice: "Room '#{@room.name}' was created." }
        format.json { render json: @room, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @room.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @room.update(room_params)
      respond_to do |format|
        format.html { redirect_to map_rooms_path(@map), notice: "Room '#{@room.name}' was updated." }
        format.json { render json: @room }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @room.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    name = @room.name
    @room.destroy
    respond_to do |format|
      format.html { redirect_to map_rooms_path(@map), notice: "Room '#{name}' was deleted." }
      format.json { head :no_content }
    end
  end

  def editor
    @rooms = @map.rooms.order(:name)
  end

  private

  def set_map
    @map = Map.find(params[:map_id])
  end

  def set_room
    @room = @map.rooms.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :x1, :y1, :x2, :y2)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You must be an admin to manage rooms."
    end
  end
end
