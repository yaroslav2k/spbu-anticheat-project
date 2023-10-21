# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions, id: :uuid do |t|
      t.references :assignment, foreign_key: true, type: :uuid

      t.string :author_name, null: false
      t.string :author_group, null: false
      t.string :type, null: false

      t.string :status, null: false, default: "created"

      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
