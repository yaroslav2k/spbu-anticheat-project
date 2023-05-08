# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid

      t.string :title, null: false
      t.string :identifier, null: false, index: { unique: true }
      t.integer :year, null: false

      t.timestamps
    end
  end
end
