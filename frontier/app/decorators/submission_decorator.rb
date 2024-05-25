# frozen_string_literal: true

class SubmissionDecorator < ApplicationDecorator
  include Memery

  delegate_all

  delegate :algorithm, :report, to: :report_builder

  memoize def plagiarism_by_author_detected?(author_name)
    report.any? do |code_clone|
      code_clone.code_fragments.any? do |code_fragment|
         author_name.downcase == code_fragment.author_name.downcase
      end
    end
  end

  private

    def report_builder
      @report_builder ||= ReportBuilder.build(context[:raw_report])
    end
end
