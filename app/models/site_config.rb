# frozen_string_literal: true

class SiteConfig < ApplicationRecord
  # Singleton pattern - only one config record should exist
  def self.instance
    first || create!
  end

  def has_location?
    latitude.present? && longitude.present?
  end
end
