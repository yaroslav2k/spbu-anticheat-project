# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid

      t.string :status, null: false, default: "created"
      t.string :identifier, index: { unique: true }

      t.timestamps
    end
  end
end
