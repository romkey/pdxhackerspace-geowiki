# frozen_string_literal: true

class CreateResourceExternalLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :resource_external_locations do |t|
      t.references :resource, null: false, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 7, null: false
      t.decimal :longitude, precision: 10, scale: 7, null: false
      t.string :url
      t.string :label

      t.timestamps
    end

    add_index :resource_external_locations, [:resource_id, :latitude, :longitude], 
              name: 'index_resource_external_locations_on_resource_coords'
  end
end

