# frozen_string_literal: true

RSpec.describe Upload::CreateService do
  describe ".result" do
    let(:submission) { create(:submission_files_group) }
    let(:attributes) do
      {
        external_id: "file-id",
        external_unique_id: "file-unique-id",
        filename: "program.py",
        mime_type: "application/x-python",
        source: "telegram"
      }
    end

    let(:telegram_bot_client_double) do
      instance_double(
        Telegram::Bot::Client,
        download_file_by_id: Struct.new(:body).new("foobar")
      )
    end

    let(:s3_client_double) do
      instance_double(
        Aws::S3::Client,
        put_object: true
      )
    end

    def perform(submission, attributes)
      described_class.result(
        submission:,
        attributes:,
        telegram_bot_client: telegram_bot_client_double,
        s3_client: s3_client_double
      )
    end

    context "with happy path" do
      specify do
        result = perform(submission, attributes)

        expect(result).to be_success
        expect(result.record).to be_persisted
        expect(result.record).to have_attributes(
          class: Upload,
          **attributes
        )

        expect(telegram_bot_client_double).to have_received(:download_file_by_id).with(
          attributes.fetch(:external_id)
        ).once
        expect(s3_client_double).to have_received(:put_object).with(
          body: "foobar",
          bucket: Rails.env,
          key: "/#{result.record.storage_key}",
          content_type: attributes.fetch(:mime_type)
        ).once
      end
    end
  end
end
