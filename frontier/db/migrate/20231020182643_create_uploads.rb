# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :uploads, id: :uuid do |t|
      t.references :uploadable, polymorphic: true, null: false, index: true, type: :uuid

      t.string :filename, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
