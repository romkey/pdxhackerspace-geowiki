# frozen_string_literal: true

class ResourceUrl < ApplicationRecord
  belongs_to :resource

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(["http", "https"]), message: "must be a valid HTTP or HTTPS URL" }
  validates :url, uniqueness: { scope: :resource_id, message: "has already been added to this resource" }
end
