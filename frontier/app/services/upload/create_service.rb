# frozen_string_literal: true

class Upload::CreateService < ApplicationService
  input :submission, type: Submission
  input :attributes, type: Hash
  input :telegram_bot_client, default: -> { Telegram::Bot::Client.default }
  input :s3_client, default: -> { Aws::S3::Client.new }

  output :record, type: Upload

  play :build_record, :perform_creation_callbacks

  private

    def call
      ApplicationRecord.transaction { super }
    end

    def build_record
      self.record = submission.uploads.create!(attributes)
    end

    def perform_creation_callbacks
      download_from_telegram
    end

    def download_from_telegram
      response = telegram_bot_client.download_file_by_id(record.external_id)

      s3_client.put_object(
        body: response.body,
        bucket: Rails.env,
        key: "/#{record.storage_key}",
        content_type: record.mime_type
      )
    end
end
