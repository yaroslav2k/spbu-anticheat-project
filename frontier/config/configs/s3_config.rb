# frozen_string_literal: true

class S3Config < ApplicationConfig
  attr_config \
    :endpoint,
    :access_key_id,
    :secret_access_key,
    :region,
    :bucket,
    force_path_style: true

  required \
    :endpoint,
    :access_key_id,
    :secret_access_key,
    :region,
    :bucket

    coerce_types \
      force_path_style: :boolean

  def bucket=(value)
    if Rails.env.test?
      super(Rails.env)
    else
      super
    end
  end
end
