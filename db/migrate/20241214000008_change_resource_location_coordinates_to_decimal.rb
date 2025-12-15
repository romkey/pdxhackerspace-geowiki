# frozen_string_literal: true

class ChangeResourceLocationCoordinatesToDecimal < ActiveRecord::Migration[8.1]
  def change
    change_column :resource_locations, :x, :decimal, precision: 6, scale: 3, null: false
    change_column :resource_locations, :y, :decimal, precision: 6, scale: 3, null: false
  end
end

