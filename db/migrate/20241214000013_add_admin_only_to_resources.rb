# frozen_string_literal: true

class AddAdminOnlyToResources < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :admin_only, :boolean, default: false, null: false
  end
end

