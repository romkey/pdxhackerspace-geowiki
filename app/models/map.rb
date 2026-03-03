# frozen_string_literal: true

class Map < ApplicationRecord
  include Journable

  has_one_attached :image

  belongs_to :parent, class_name: "Map", optional: true, inverse_of: :children
  has_many :children, class_name: "Map", foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent

  has_many :map_maintainers, dependent: :destroy
  has_many :maintainers, through: :map_maintainers, source: :user

  has_many :resource_locations, dependent: :destroy
  has_many :resources, through: :resource_locations

  has_many :rooms, dependent: :destroy

  validates :name, presence: true
  validates :slack_channel, format: { with: /\A#?[\w-]+\z/, allow_blank: true }
  validates :image,
            content_type: {
              in: ["image/png", "image/jpeg", "image/gif", "image/webp"],
              message: "must be a PNG, JPEG, GIF, or WebP",
            },
            size: { less_than: 10.megabytes, message: "must be less than 10MB" }

  before_save :ensure_single_default

  scope :default, -> { where(is_default: true) }

  def self.default_map
    find_by(is_default: true)
  end

  def ancestors
    result = []
    current = parent
    while current
      result << current
      current = current.parent
    end
    result
  end

  def breadcrumb_trail
    ancestors.reverse + [self]
  end

  def maintainer?(user)
    maintainers.include?(user)
  end

  def can_edit?(user)
    return true if user.admin?

    maintainer?(user)
  end

  def has_scale?
    scale_pixels.present? && scale_real_value.present? && scale_pixels > 0
  end

  def percent_to_real_distance(percent)
    return nil unless has_scale?

    (percent / scale_pixels) * scale_real_value
  end

  def room_for_point(x, y)
    rooms.find { |room| room.contains_point?(x, y) }
  end

  def position_description_for(x, y, include_distance: true)
    room = room_for_point(x, y)
    return nil unless room

    room.position_description_for(x, y, include_distance: include_distance)
  end

  private

  def ensure_single_default
    return unless is_default? && is_default_changed?

    Map.where.not(id: id).update_all(is_default: false)
  end
end
