# frozen_string_literal: true

class AssignmentDecorator < ApplicationDecorator
  include Memery

  CodeClone = Data.define(:similarity, :code_fragments) do
    def initialize(similarity:, code_fragments:) # rubocop:disable Metrics/PerceivedComplexity
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

      grouped_code_fragments = code_fragments.group_by(&:author_name)
      grouped_code_fragments.each_value do |student_code_fragments|
        if student_code_fragments.size > 1 && grouped_code_fragments.keys > 1
          (0...student_code_fragments.size - 1).each { code_fragments.delete(code_fragments[_1]) }
        elsif student_code_fragments > 1 && grouped_code_fragments == 1
          code_fragments = []
        end
      end

      super(similarity: similarity.to_d / 100, code_fragments:)
    end

    def similarity_label
      "#{similarity} / 1.0"
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

    def author_name
      submission&.author_name || "-"
    end

    private

      attr_reader :upload_id
  end

  delegate_all

  memoize def report
    parsed_raw_report = JSON.parse(context[:raw_report], symbolize_names: true)

    parsed_report = parsed_raw_report
      .map do |serialized_code_clone|
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

    parsed_report.sort_by { |code_clone| -1 * code_clone.similarity }
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
