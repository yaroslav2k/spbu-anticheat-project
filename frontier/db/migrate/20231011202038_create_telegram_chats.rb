# frozen_string_literal: true

class CreateTelegramChats < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_chats, id: :uuid do |t|
      t.string :external_identifier, null: false, index: { unique: true }
      t.string :username, null: false

      t.string :name
      t.string :group

      t.references :last_submitted_course, foreign_key: { to_table: :courses }, type: :uuid

      t.string :status, null: false, default: "created"

      t.timestamps
    end
  end
end
