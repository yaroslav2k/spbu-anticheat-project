# frozen_string_literal: true

class Storage
  def initialize(config)
    @config = config
  end

  def public_url(key)
    "https://#{host}/storage/development/#{key}" # FIXME
  end

  PRIMARY = new(Rails.application.credentials.services.s3)

  private

    def host
      Rails.application.config.x.ip_address
    end

    attr_reader :config
end
