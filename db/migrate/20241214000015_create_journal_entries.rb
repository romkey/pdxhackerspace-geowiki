# frozen_string_literal: true

class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      t.references :journable, polymorphic: true, null: false
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.text :details
      t.json :changes_made

      t.timestamps
    end

    add_index :journal_entries, :action
    add_index :journal_entries, :created_at
  end
end

