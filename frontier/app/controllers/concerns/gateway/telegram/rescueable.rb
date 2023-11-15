# frozen_string_literal: true

module Gateway::Telegram::Rescueable
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |exception|
      Rails.logger.error(Array.wrap(exception.message) + exception.backtrace).join($RS)

      reply_with(event_response(:failed_to_save_record, {}))

      # raise exception unless Rails.env.production?

      head :ok
    end
  end
end
