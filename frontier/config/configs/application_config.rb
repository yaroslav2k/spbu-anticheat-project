# frozen_string_literal: true

class ApplicationConfig < Anyway::Config
  def self.validate_url!(attribute)
    on_load do
      Addressable::URI.parse(public_send(attribute))

      nil
    end
  end
end
