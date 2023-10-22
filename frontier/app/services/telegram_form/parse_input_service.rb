# frozen_string_literal: true

class TelegramForm::ParseInputService < ApplicationService
  subject :params

  result_on_success :input

  Input = Struct.new(:chat_object, :message, :document, keyword_init: true) do
    def chat_id = chat_object&.[](:id)

    def command_type = ((message || [])[1..].presence_in(%w[start submit]) || "unknown").inquiry
  end

  def call
    success! input: build_input_object
  end

  private

    def build_input_object
      Input.new(
        chat_object: params.dig(:message, :chat).presence,
        message: params.dig(:message, :text).presence,
        document: params.dig(:message, :document).presence
      )
    end
end
