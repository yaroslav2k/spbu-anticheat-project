# frozen_string_literal: true

Aws.config.update(Rails.application.credentials.services.s3)
