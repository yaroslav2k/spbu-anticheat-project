# frozen_string_literal: true

class HTTPClient::Detector
  include HTTParty

  headers "Content-Type" => "application/json",

  def initialize(config)
    @config = config
    @access_token = config.fetch(:access_token)

    self.class.base_uri config.fetch(:base_uri)

  end

  def detect(task_spec)
    self.class.post(
      "/todo",
      body: task_spec,
      headers: {
        "Authorization" => "Bearer #{access_token}"
      }
    )
  end

  private

    attr_reader :config, :access_token
end