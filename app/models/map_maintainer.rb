# frozen_string_literal: true

class MapMaintainer < ApplicationRecord
  belongs_to :map
  belongs_to :user

  validates :user_id, uniqueness: { scope: :map_id, message: "is already a maintainer of this map" }
end
