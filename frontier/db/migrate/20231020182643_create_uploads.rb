# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :uploads do |t|
      t.belongs_to :uploadable, polymorphic: true, null: false

      t.string :filename, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
