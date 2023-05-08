# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions, id: :uuid do |t|
      t.references :assignment, foreign_key: true, type: :uuid

      t.string :url, null: false
      t.string :branch, null: false, default: "master"
      t.string :author, null: false

      t.string :status, null: false, default: "created"

      t.timestamps
    end
  end
end
