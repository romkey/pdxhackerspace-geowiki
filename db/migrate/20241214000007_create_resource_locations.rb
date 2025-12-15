class CreateResourceLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :resource_locations do |t|
      t.references :resource, null: false, foreign_key: true
      t.references :map, null: false, foreign_key: true
      t.integer :x, null: false
      t.integer :y, null: false

      t.timestamps
    end

    add_index :resource_locations, [:resource_id, :map_id]
  end
end

