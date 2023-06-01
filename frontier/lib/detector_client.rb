# frozen_string_literal: true

class DetectorClient
  REQUEST_IDENTIFIER_HEADER = "Request-ID"
  private_constant :REQUEST_IDENTIFIER_HEADER

  delegate :assignment, to: :submission, private: true

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
    @config = config
    @access_token = config.fetch(:access_token)

    self.class.base_uri config.fetch(:base_uri)
  end

  def detect(submission)
    request_body = request_body(submission).to_json

    with_request_identifier do |request_identifier|
      self.class.post(
        "/detection/compare-repositories",
        body: request_body,
        headers: {
          "Authorization" => authorization_value(access_token),
          REQUEST_IDENTIFIER_HEADER => request_identifier
        }
      )
    end
  end

  private

    def request_body(submission)
      {
        "algorithm" => algorithm.to_h,
        "assignment" => "#{submission.assignment.storage_key}/submissions",
        "result_key" => submission.assignment.report_storage_key,
        "result_path" => api_submission_path(submission.id)
      }
    end

    def algorithm
      @algorithm ||= Algorithm.new(
        name: "LCS",
        n: 2,
        threshold: 0.7
      )
    end

    def authorization_value(access_token)
      "Bearer #{access_token}"
    end

    def with_request_identifier
      yield SecureRandom.uuid
    end

    attr_reader :config, :access_token
end
