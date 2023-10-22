# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up { enable_extension "citext" }
      dir.down { disable_extension "citext" }
    end

    create_table :courses, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid

      t.citext :title, null: false, index: { unique: true }
      t.string :semester, null: false
      t.integer :year, null: false

      t.timestamps
    end
  end
end
