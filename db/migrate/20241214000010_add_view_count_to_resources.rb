# frozen_string_literal: true

class AddViewCountToResources < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :view_count, :integer, default: 0, null: false
    add_index :resources, :view_count
  end
end

