# frozen_string_literal: true

class AddDefaultToMaps < ActiveRecord::Migration[8.1]
  def change
    add_column :maps, :is_default, :boolean, default: false, null: false
    add_index :maps, :is_default, where: "is_default = true", unique: true
  end
end

