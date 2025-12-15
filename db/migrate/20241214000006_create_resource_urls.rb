class CreateResourceUrls < ActiveRecord::Migration[8.1]
  def change
    create_table :resource_urls do |t|
      t.references :resource, null: false, foreign_key: true
      t.string :url, null: false
      t.string :label

      t.timestamps
    end

    add_index :resource_urls, [:resource_id, :url], unique: true
  end
end

