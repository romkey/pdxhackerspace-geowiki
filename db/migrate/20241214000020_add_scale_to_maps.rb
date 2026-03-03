# frozen_string_literal: true

class AddScaleToMaps < ActiveRecord::Migration[8.0]
  def change
    add_column :maps, :scale_pixels, :decimal, precision: 10, scale: 3
    add_column :maps, :scale_real_value, :decimal, precision: 10, scale: 3
    add_column :maps, :scale_unit, :string, default: "feet"
  end
end
