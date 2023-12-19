# frozen_string_literal: true

class TelegramForm::ParseInputService < ApplicationService
  AVAILABLE_COMMANDS = %w[start preview reset submit].freeze
  private_constant :AVAILABLE_COMMANDS

  subject :params

  result_on_success :input

  Input = Struct.new(:chat_object, :message, :document, keyword_init: true) do
    def chat_id = chat_object&.[](:id)

    def username = chat_object&.[](:username)

    def command_type = ((message || [])[1..].presence_in(AVAILABLE_COMMANDS) || "unknown").inquiry

    def git_revision
      @git_revision ||= if (parts = message&.split)&.size == 2 && Assignment::VerifyURLService.call(parts.first).success?
        parts
      end
    end

    def git_revision?
      git_revision.present?
    end
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
