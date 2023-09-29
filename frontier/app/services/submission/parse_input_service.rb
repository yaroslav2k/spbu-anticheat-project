# frozen_string_literal: true

class Submission::ParseInputService < ApplicationService
  subject :data

  class Input
    AVAILABLE_COMMANDS = %w[/start /send].freeze

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def command_type
      return "unknown".inquiry unless command.in?(AVAILABLE_COMMANDS)

      command[1..].inquiry
    end

    def assignment_id
      tokens[1]
    end

    def submission_type
      return :git if options.key?("git-url")
      return :file if type.file?

      :unknown
    end

    def valid?
      Rails.logger.info("OPTIONS-----------------")
      Rails.logger.info(options)
      return false if type.unknown?
      return false if assignment_id.blank?
      return false if command_type.unknown?
      return false if options.key?("git-url") && !Assignment::VerifyURLService.call(options.fetch("git-url")).success?

      true
    end

    def options
      @options ||= Dotenv::Parser.call(message.split("\n")[1..].join("\n")).deep_symbolize_keys
    end

    private

      def command = @command ||= tokens[0]

      def message
        @message ||= if type.text?
          data.fetch(:message).fetch(:text)
                     elsif type.file?
          data.fetch(:message).fetch(:caption)
                     end.presence || ""
      end

      def tokens
        return @tokens if defined?(@tokens)

        @tokens = message.split.map(&:strip)
      end

      def type
        @type ||= if data.dig(:message, :text).present?
          :text
                  elsif data.dig(:message, :caption).present?
          :file
                  else
          :unknown
                  end.to_s.inquiry
      end
  end

  def call
    return fail! unless data

    Input.new(data)
  end
end
