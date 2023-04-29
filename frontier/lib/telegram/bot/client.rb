# frozen_string_literal: true

class Telegram::Bot::Client
  include HTTParty

  base_uri "https://api.telegram.org"

  headers "Content-Type" => "application/json"

  def initialize(config)
    @api_token = config.fetch(:api_token)
  end

  def send_message(chat_id:, text:)
    response = post_to_bot(
      "/sendMessage",
      chat_id: chat_id,
      text: text
      # parse_mode: "HTML"
    )

    raise response.inspect unless response.success?
  end

  private

    attr_reader :api_token

    def post_to_bot(path, **body)
      self.class.post("/bot#{api_token}#{path}", body: body.to_json)
    end
end
