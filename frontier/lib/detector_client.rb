# frozen_string_literal: true

class DetectorClient
  include HTTParty

  headers "Content-Type" => "application/json"

  def initialize(config)
    @config = config
    @access_token = config.fetch(:access_token)

    self.class.base_uri config.fetch(:base_uri)
  end

  def detect(task_spec)
    request_body = request_body(task_spec).to_json

    Rails.logger.debug "request body: #{request_body}"
    self.class.post(
      "/detection/detect-fragments",
      body: request_body,
      headers: {
        "Authorization" => "Bearer #{access_token}"
      }
    )
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

    attr_reader :config, :access_token
end
