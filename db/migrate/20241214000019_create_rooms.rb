# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.references :map, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :x1, precision: 6, scale: 3, null: false
      t.decimal :y1, precision: 6, scale: 3, null: false
      t.decimal :x2, precision: 6, scale: 3, null: false
      t.decimal :y2, precision: 6, scale: 3, null: false

      t.timestamps
    end

    add_index :rooms, [:map_id, :name], unique: true
  end
end
