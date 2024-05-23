# frozen_string_literal: true

class DetectorClient
  REQUEST_IDENTIFIER_HEADER = "Request-ID"
  private_constant :REQUEST_IDENTIFIER_HEADER

  include Rails.application.routes.url_helpers

  Algorithm = Data.define(:name, :threshold, :n) do
    def initialize(name:, threshold:, n: nil) # rubocop:disable Naming/MethodParameterName
      super(name:, threshold:, n:)
    end

    def to_h
      {
        "name" => name,
        params: { "threshold" => threshold, "n" => n }.compact_blank
      }
    end
    alias_method :to_hash, :to_h
  end

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

    def nicad_request_body(assignment, submission)
      target_submissions = assignment.submissions.files_group
      target_uploads = Upload.where(uploadable_type: Submission.to_s, uploadable_id: target_submissions.ids).map(&:storage_key)

      {
        "algorithm" => algorithm(assignment).to_h,
        "result_key" => assignment.nicad_report_storage_key,
        "resources" => target_uploads,
        "revision" => assignment.id
      }.tap do |hash|
        hash["result_path"] = gateway_detector_submission_path(submission.id) if submission
      end
    end

    def request_body(assignment, submission)
      {
        "algorithm" => algorithm(assignment).to_h,
        "assignment" => "#{assignment.storage_key}/submissions",
        "result_key" => assignment.report_storage_key
      }.tap do |hash|
        hash["result_path"] = gateway_detector_submission_path(submission.id) if submission
      end
    end

    def algorithm(assignment)
      Algorithm.new(
        name: "NICAD",
        threshold: assignment.threshold
      )

      # @algorithm ||= Algorithm.new(
      #   name: "LCS",
      #   n: assignment.ngram_size,
      #   threshold: assignment.threshold
      # )
    end

    def authorization_value(access_token) = "Bearer #{access_token}"

    def with_request_identifier = yield SecureRandom.uuid
end
