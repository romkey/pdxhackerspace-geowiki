# frozen_string_literal: true

class AddParentToResources < ActiveRecord::Migration[8.1]
  def change
    # add_reference already creates an index by default
    add_reference :resources, :parent, foreign_key: { to_table: :resources }, null: true
  end
end

