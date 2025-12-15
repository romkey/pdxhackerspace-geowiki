# frozen_string_literal: true

class AddAddressToResourceExternalLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :resource_external_locations, :address, :string
  end
end

