# frozen_string_literal: true

class Telegram::Bot::Client
  include HTTParty

  HTTPError = Class.new(StandardError)

  base_uri "https://api.telegram.org"

  headers "Content-Type" => "application/json"

  def self.default
    new(Frontier.config.telegram_bot_config)
  end

  def initialize(config)
    @api_token = config.api_token
  end

  def send_message(chat_id:, text:)
    response = post_to_bot(
      "/sendMessage",
      chat_id:,
      text:
    )

    raise_on_erroneous_response(response)
    response
  end

  def fetch_file(id)
    response = post_to_bot(
      "/getFile",
      file_id: id
    )

    raise_on_erroneous_response(response)

    response
  end

  def download_file(path)
    post_to_file_api(path).tap { raise_on_erroneous_response(_1) }
  end

  def download_file_by_id(id)
    response = fetch_file(id)
    file_path = response.parsed_response.fetch("result").fetch("file_path")

    download_file(file_path)
  end

  private

    attr_reader :api_token

    def post_to_bot(path, **body)
      self.class.post("/bot#{api_token}#{path}", body: body.to_json)
    end

    def post_to_file_api(path)
      self.class.get("/file/bot#{api_token}/#{path}")
    end

    def raise_on_erroneous_response(response)
      raise HTTPError, response.inspect unless response.success?
    end
end
