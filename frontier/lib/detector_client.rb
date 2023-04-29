# frozen_string_literal: true

class DetectorClient
  REQUEST_IDENTIFIER_HEADER = "Request-ID"
  private_constant :REQUEST_IDENTIFIER_HEADER

  include HTTParty

  headers "Content-Type" => "application/json"

  def initialize(config)
    @config = config
    @access_token = config.fetch(:access_token)

    self.class.base_uri config.fetch(:base_uri)
  end

  def detect(task_spec)
    request_body = request_body(task_spec).to_json

    with_request_identifier do |request_identifier|
      self.class.post(
        "/detection/detect-fragments",
        body: request_body,
        headers: {
          "Authorization" => authorization_value(access_token),
          REQUEST_IDENTIFIER_HEADER => request_identifier
        }
      )
    end
  end

  private

    def request_body(task_spec)
      {
        "algorithm" => "LCS",
        "params" => {
          "n" => 2,
          "threshold" => 0.45
        },
        "fragments" => task_spec
      }
    end

    def authorization_value(access_token)
      "Bearer #{access_token}"
    end

    def with_request_identifier
      yield SecureRandom.uuid
    end

    attr_reader :config, :access_token
end
