# frozen_string_literal: true

class Assignment::DetectJob < ApplicationJob
  sidekiq_options retry: false

  def perform(assignment, submission)
    Assignment::DetectService.call(assignment:, submission:)
  end
end
