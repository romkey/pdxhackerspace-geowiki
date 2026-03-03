# frozen_string_literal: true

class ResourceLocation < ApplicationRecord
  belongs_to :resource
  belongs_to :map

  validates :x, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :y, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def room
    map.room_for_point(x, y)
  end

  def position_description(include_distance: true)
    map.position_description_for(x, y, include_distance: include_distance)
  end
end

