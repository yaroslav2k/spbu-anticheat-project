# frozen_string_literal: true

class AssignmentDecorator < ApplicationDecorator
  include Memery

  CodeClone = Data.define(:similarity, :code_fragments) do
    def initialize(similarity:, code_fragments:)
      unless similarity.is_a?(Numeric) && (0..100).cover?(similarity)
        raise ArgumentError, <<~HEREDOC
          Expected `similarity` to be a floating-point number within 0..1 range.
        HEREDOC
      end

      unless code_fragments.is_a?(Array) && code_fragments.all? { _1.is_a?(CodeFragment) }
        raise ArgumentError, <<~HEREDOC
          Expected `code_fragments` to be an instance of array with
          elements of type `CodeFragment`.
        HEREDOC
      end

      super(similarity: similarity.to_d / 100, code_fragments:)
    end
  end

  CodeFragment = Data.define(:identifier, :line_start, :line_end) do
    def initialize(identifier:, line_start:, line_end:)
      raise ArgumentError, "Expected `identifier` to be a string, got `#{identifier.inspect}`" unless identifier.is_a?(String)

      unless line_start.is_a?(Integer) && line_start.positive?
        raise ArgumentError, "Expected `line_start` to be a positive integer, got `#{line_start.inspect}`"
      end

      unless line_end.is_a?(Integer) && line_end.positive?
        raise ArgumentError, "Expected `line_end` to be a positive integer, got `#{line_end.inspect}`"
      end

      @upload_id ||= identifier.split("/").last.gsub(/\..+\Z/, "")

      load_submission

      super(identifier:, line_start:, line_end:)
    end

    def upload
      return @upload if defined?(@upload)

      @upload = suppress(ActiveRecord::RecordNotFound) do
        Upload.find(upload_id)
      end
    end

    def submission
      return @submission if defined?(@submission)

      @submission = upload.uploadable
    end
    alias_method :load_submission, :submission

    private

      attr_reader :upload_id
  end

  delegate_all

  memoize def report
    parsed_report = JSON.parse(context[:raw_report], symbolize_names: true)

    parsed_report.map do |serialized_code_clone|
      CodeClone.new(
        similarity: serialized_code_clone[:similarity],
        code_fragments: serialized_code_clone.fetch(:code_fragments).map do |serialized_code_fragment|
          CodeFragment.new(
            identifier: serialized_code_fragment.fetch(:identifier),
            line_start: serialized_code_fragment.fetch(:line_start),
            line_end: serialized_code_fragment.fetch(:line_end)
          )
        end
      )
    end
  end

  def submission_field(code_fragment)
    submission = code_fragment.submission
    upload = code_fragment.upload

    if submission
      h.link_to "#{submission.id} (#{upload.filename})", h.admin_submission_url(submission)
    else
      "-"
    end
  end
end
