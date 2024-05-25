# frozen_string_literal: true

class URLValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super

    @domain = options[:domain]
  end

  def validate_each(record, attribute, value)
    return if valid_url?(value) && !domain

    if !valid_url?(value)
      record.errors.add(attribute, :invalid_uri)
    elsif !uri.host.in?(Array.wrap(domain))
      record.errors.add(attribute, :invalid_domain)
    end
  end

  private

    attr_reader :domain, :uri

    def valid_url?(value)
      @uri = URI.parse(value)
      @uri.scheme.in?(%w[http https])
    rescue ::URI::InvalidURIError
      false
    end
end
