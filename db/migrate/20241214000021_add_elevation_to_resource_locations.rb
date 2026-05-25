class AddElevationToResourceLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :resource_locations, :elevation, :decimal, precision: 10, scale: 2
  end
end
