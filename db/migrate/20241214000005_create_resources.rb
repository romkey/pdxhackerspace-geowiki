class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string :name, null: false
      t.boolean :internal, default: true, null: false
      t.decimal :longitude, precision: 10, scale: 7
      t.decimal :latitude, precision: 10, scale: 7

      t.timestamps
    end

    add_index :resources, :name
    add_index :resources, :internal
  end
end

