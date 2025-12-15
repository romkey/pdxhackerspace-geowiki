class ResourceLocation < ApplicationRecord
  belongs_to :resource
  belongs_to :map

  validates :x, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :y, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end

