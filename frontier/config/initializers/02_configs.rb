# frozen_string_literal: true

unless ENV.key?("SKIP_CONFIGS")
  Frontier.config.redis_config = RedisConfig.new
  Frontier.config.detector_config = DetectorConfig.new
  Frontier.config.telegram_bot_config = TelegramBotConfig.new
  Frontier.config.s3_config = S3Config.new
end
