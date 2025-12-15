class AddIconToResources < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :icon, :string
  end
end

