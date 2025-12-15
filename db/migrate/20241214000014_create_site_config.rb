# frozen_string_literal: true

class CreateSiteConfig < ActiveRecord::Migration[8.1]
  def change
    create_table :site_configs do |t|
      t.string :organization_name
      t.text :address
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7

      t.timestamps
    end
  end
end

