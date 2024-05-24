# frozen_string_literal: true

class Detector::Client
  REQUEST_IDENTIFIER_HEADER = "Request-ID"
  private_constant :REQUEST_IDENTIFIER_HEADER

  include Rails.application.routes.url_helpers

  include HTTParty

  headers "Content-Type" => "application/json"

  def initialize(config)
    @config = config
  end

  def detect(assignment, submission)
    request_body = request_body(assignment, submission).to_json

    with_request_identifier do |request_identifier|
      self.class.post(
        "#{config.base_uri}/detection/compare-repositories",
        body: request_body,
        headers: {
          "Authorization" => authorization_value(config.access_token),
          REQUEST_IDENTIFIER_HEADER => request_identifier
        }
      )
    end
  end

  def detect_clones(assignment, submission)
    request_body = nicad_request_body(assignment, submission).to_json

    with_request_identifier do |request_identifier|
      self.class.post(
        "#{config.base_uri}/detection/detect-clones",
        body: request_body,
        headers: {
          "Authorization" => authorization_value(config.access_token),
          REQUEST_IDENTIFIER_HEADER => request_identifier
        }
      )
    end
  end

  private

    attr_reader :config

    def build_request_body(assignment, submission)
      target_submissions = assignment.submissions.files_group
      target_uploads = Upload.where(uploadable_type: Submission.to_s, uploadable_id: target_submissions.ids).map(&:storage_key)

      {
        "algorithm" => algorithm(assignment),
        "result_key" => assignment.nicad_report_storage_key,
        "resources" => target_uploads,
        "revision" => assignment.id
      }.tap do |hash|
        hash["result_path"] = gateway_detector_submission_path(submission.id) if submission
      end
    end

    def algorithm(assignment)
      if assignment.algorithm.to_sym == :nicad
        {
          name: "nicad",
          params: {
            threshold: assignment.nicad.threshold
          }
        }
      elsif assignment.algorithm.to_sym == "lcs_baseline"
        {
          name: "lcs_baseline",
          n: assignment.lcs_baseline.ngram_size,
          threshold: assignment.lcs_baseline.threshold
        }
      end
    end

    def authorization_value(access_token) = "Bearer #{access_token}"

    def with_request_identifier = yield SecureRandom.uuid
end
