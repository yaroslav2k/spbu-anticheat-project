# frozen_string_literal: true

# deprecated
class Submission::BuildService < ApplicationService
  subject :input

  result_on_failure :reason
  result_on_success :submission

  def call
    case input.submission_type.to_sym
    when :git
      Submission::Git.new(
        author: author,
        url: input.options.fetch("git-url"),
        branch: input.options.fetch("branch", "master")
      )
    when :file
      Submission::File.new(
        author: author,
        external_id: input.data.dig(:message, :document, :file_id),
        external_unique_id: input.data.dig(:message, :document, :file_unique_id),
        filename: input.data.dig(:message, :document, :file_name),
        mime_type: input.data.dig(:message, :document, :mime_type)
      )
    else
      fail! reason: :unknown_sumbission_type
    end
  end

  private

    def author
      if input.options.key?(:author)
        input.options.fetch(:author)
      else
        "#{chat_object[:first_name]} #{chat_object[:last_name]} (#{chat_object[:username]})"
      end
    end

    def chat_object
      @chat_object ||= input.data.dig(:message, :chat)
    end
end
