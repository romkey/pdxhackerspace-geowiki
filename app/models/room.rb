# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :map

  validates :name, presence: true, uniqueness: { scope: :map_id }
  validates :x1, :y1, :x2, :y2, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def left
    [x1, x2].min
  end

  def right
    [x1, x2].max
  end

  def top
    [y1, y2].min
  end

  def bottom
    [y1, y2].max
  end

  def width_percent
    right - left
  end

  def height_percent
    bottom - top
  end

  def center_x
    (left + right) / 2.0
  end

  def center_y
    (top + bottom) / 2.0
  end

  def contains_point?(x, y)
    x >= left && x <= right && y >= top && y <= bottom
  end

  def position_description_for(x, y, include_distance: true)
    return nil unless contains_point?(x, y)

    relative_x = (x - left) / width_percent
    relative_y = (y - top) / height_percent

    horizontal = if relative_x < 0.33
                   "west"
                 elsif relative_x > 0.67
                   "east"
                 else
                   nil
                 end

    vertical = if relative_y < 0.33
                 "north"
               elsif relative_y > 0.67
                 "south"
               else
                 nil
               end

    position = [vertical, horizontal].compact.join("")
    position = "center" if position.empty?

    base_description = "In #{name}, #{position_to_words(position)}"

    if include_distance && map.has_scale?
      distance_info = nearest_wall_distance(x, y)
      if distance_info
        base_description += " (#{distance_info[:distance]} #{map.scale_unit} from #{distance_info[:wall]} wall)"
      end
    end

    base_description
  end

  def nearest_wall_distance(x, y)
    return nil unless map.has_scale?

    distances = {
      north: y - top,
      south: bottom - y,
      west: x - left,
      east: right - x
    }

    nearest = distances.min_by { |_, d| d }
    wall_name = nearest[0]
    percent_distance = nearest[1]

    real_distance = map.percent_to_real_distance(percent_distance)
    { wall: wall_name, distance: real_distance.round(1) }
  end

  private

  def position_to_words(position)
    case position
    when "northwest" then "near the northwest corner"
    when "north" then "near the north wall"
    when "northeast" then "near the northeast corner"
    when "west" then "near the west wall"
    when "center" then "in the center"
    when "east" then "near the east wall"
    when "southwest" then "near the southwest corner"
    when "south" then "near the south wall"
    when "southeast" then "near the southeast corner"
    else "at position #{position}"
    end
  end
end
