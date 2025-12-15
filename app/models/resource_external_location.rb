# frozen_string_literal: true

class ResourceExternalLocation < ApplicationRecord
  belongs_to :resource

  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(["http", "https"]), allow_blank: true }
end
