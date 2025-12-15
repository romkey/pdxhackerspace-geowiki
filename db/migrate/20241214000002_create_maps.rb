class CreateMaps < ActiveRecord::Migration[8.1]
  def change
    create_table :maps do |t|
      t.string :name, null: false
      t.string :slack_channel
      t.references :parent, foreign_key: { to_table: :maps }

      t.timestamps
    end

    add_index :maps, :name
  end
end

