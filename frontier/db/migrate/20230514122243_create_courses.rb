# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid

      t.string :title, null: false
      t.string :semester, null: false
      t.integer :year, null: false

      t.timestamps
    end
  end
end
