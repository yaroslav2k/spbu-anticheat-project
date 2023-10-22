# frozen_string_literal: true

class CreateTelegramForms < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_forms, id: :uuid do |t|
      t.references :course, index: true, foreign_key: true, type: :uuid
      t.references :assignment, index: true, foreign_key: true, type: :uuid
      t.references :submission, index: true, foreign_key: true, type: :uuid

      t.string :chat_identifier, index: true
      t.string :author_name
      t.string :author_group

      t.string :stage, null: false, default: "initial"

      t.timestamps
    end
  end
end
