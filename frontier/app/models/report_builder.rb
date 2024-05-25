# frozen_string_literal: true

class ReportBuilder
  include Memery

  def self.build(...)
    new(...)
  end

  def initialize(raw_report)
    @parsed_raw_report = JSON.parse(raw_report, symbolize_names: true)
  end

  memoize def algorithm = parsed_raw_report[:algorithm]

  memoize def report
    parsed_report = parsed_raw_report[:result]
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

    parsed_report
      .select { |code_clone| code_clone.code_fragments.size.positive? }
      .sort_by { |code_clone| -1 * code_clone.similarity }
  end

  private

    attr_reader :parsed_raw_report
end
