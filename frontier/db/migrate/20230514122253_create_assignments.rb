# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments, id: :uuid do |t|
      t.references :course, foreign_key: true, null: false, type: :uuid

      t.citext :title, null: false

      t.jsonb :options, null: false, default: {}

      t.integer :submissions_count

      t.timestamps
    end

    add_index :assignments, %i[course_id title], unique: true
  end
end
