# frozen_string_literal: true

class Storage
  def initialize(config)
    @config = config
  end

  def public_url(key)
    "https://#{host}/storage/#{bucket}/#{key}" # FIXME
  end

  PRIMARY = new(Frontier.config.s3_config)

  private

    def host
      Rails.application.config.x.ip_address
    end

    def bucket
      Rails.env
    end

    attr_reader :config
end
