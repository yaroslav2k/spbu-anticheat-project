# frozen_string_literal: true

class TelegramForm::ParseInputService < ApplicationService
  AVAILABLE_COMMANDS = %w[start preview reset submit].freeze
  private_constant :AVAILABLE_COMMANDS

  input :params, type: Hash

  output :input

  play :build_input_object

  GitRevision = Data.define(:repository_url, :branch) do
    def initialize(repository_url:, branch:)
      super(repository_url: repository_url.strip, branch: branch.presence || "main")
    end
  end

  Input = Struct.new(:chat_object, :message, :document, keyword_init: true) do
    def chat_id = chat_object&.[](:id)

    def username = chat_object&.[](:username)

    def command_type = ((message || [])[1..].presence_in(AVAILABLE_COMMANDS) || "unknown").inquiry

    def git_revision
      @git_revision ||= begin
        parts = message&.split

        GitRevision.new(repository_url: parts[0], branch: parts[1]) if parts.present?
      end
    end

    def git_revision?
      !!git_revision
    end
  end

  private

    def build_input_object
      self.input = Input.new(
        chat_object: params.dig(:message, :chat).presence,
        message: params.dig(:message, :text).presence,
        document: params.dig(:message, :document).presence
      )
    end
end
