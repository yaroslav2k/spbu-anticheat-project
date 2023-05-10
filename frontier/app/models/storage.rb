# frozen_string_literal: true

class Storage
  def initialize(config)
    @config = config
  end

  def public_url(key)
    "http://localhost/storage/development/#{key}" # FIXME
  end

  PRIMARY = new(Rails.application.credentials.services.s3)

  private

    attr_reader :config
end
