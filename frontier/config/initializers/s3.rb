# frozen_string_literal: true

Aws.config.update(Frontier.config.s3_config.to_h.without(:bucket))
