class CreateMapMaintainers < ActiveRecord::Migration[8.1]
  def change
    create_table :map_maintainers do |t|
      t.references :map, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :map_maintainers, [:map_id, :user_id], unique: true
  end
end

