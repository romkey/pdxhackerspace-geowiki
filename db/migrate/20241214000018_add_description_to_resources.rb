# frozen_string_literal: true

class AddDescriptionToResources < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :description, :text
  end
end

