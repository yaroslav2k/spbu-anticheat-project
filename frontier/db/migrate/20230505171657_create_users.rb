# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :username, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
