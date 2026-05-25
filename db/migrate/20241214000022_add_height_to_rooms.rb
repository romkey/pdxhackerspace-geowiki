class AddHeightToRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :height, :decimal, precision: 10, scale: 2
  end
end
