# frozen_string_literal: true

class DetectorClient
  REQUEST_IDENTIFIER_HEADER = "Request-ID"
  private_constant :REQUEST_IDENTIFIER_HEADER

  include Rails.application.routes.url_helpers

  Algorithm = Struct.new(:name, :n, :threshold, keyword_init: true) do
    def to_h
      { "name" => name, "params" => { "n" => n, "threshold" => threshold } }
    end
    alias_method :to_hash, :to_h
  end

  include HTTParty

  headers "Content-Type" => "application/json"

  def initialize(config)
    @access_token = config.fetch(:access_token)
    @base_uri = config.fetch(:base_uri)
  end

  def detect(assignment, submission)
    request_body = request_body(assignment, submission).to_json

    with_request_identifier do |request_identifier|
      self.class.post(
        "#{base_uri}/detection/compare-repositories",
        body: request_body,
        headers: {
          "Authorization" => authorization_value(access_token),
          REQUEST_IDENTIFIER_HEADER => request_identifier
        }
      )
    end
  end

  private

    attr_reader :base_uri, :access_token

    def request_body(assignment, submission)
      {
        "algorithm" => algorithm(assignment).to_h,
        "assignment" => "#{assignment.storage_key}/submissions",
        "result_key" => assignment.report_storage_key
      }.tap do |hash|
        hash["result_path"] = api_submission_path(submission.id) if submission
      end
    end

    def algorithm(assignment)
      @algorithm ||= Algorithm.new(
        name: "LCS",
        n: assignment.ngram_size,
        threshold: assignment.threshold
      )
    end

    def authorization_value(access_token)
      "Bearer #{access_token}"
    end

    def with_request_identifier
      yield SecureRandom.uuid
    end
end
