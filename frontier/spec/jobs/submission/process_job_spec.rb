# frozen_string_literal: true

RSpec.describe Submission::ProcessJob do
  describe "#perform" do
    def perform(submission)
      described_class.perform_now(submission)
    end

    before do
      response_double = instance_double(HTTParty::Response, success?: true)
      evaluator_double = instance_double(Proc, call: response_double, :[] => response_double)
      stub_const("GitRemoteValidator::HTTP_REQUEST_EVALUATOR", evaluator_double)
    end

    context "with submission of `git` kind" do
      let(:submission) { create(:submission_git) }

      context "with happy path" do
        let(:s3_client_double) { instance_double(Aws::S3::Client, put_object: true) }

        before do
          allow(Git).to receive(:clone).and_return(true)
          allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
          allow(Assignment::DetectService).to receive(:call).and_return(
            ServiceActor::Result.to_result(success: false, exception: nil)
          )
        end

        specify do
          perform(submission)

          expect(Git).to have_received(:clone).with(
            submission.url, an_instance_of(String), an_instance_of(Hash)
          ).ordered.once
        end
      end
    end

    context "with submission of `files_group` kind" do
      let(:submission) { create(:submission_files_group) }
      let!(:upload) { create(:upload, uploadable: submission) }
      let(:identifier) { "2cb7a6ae7c53c8177891df317ecfc668" }

      let(:file_double) { instance_double(File) }
      let(:s3_client_double) { instance_double(Aws::S3::Client, get_object: true, put_object: true) }

      context "with happy path" do
        before do
          allow(FileUtils).to receive(:mkdir_p) { |*arguments| arguments }
          allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
          allow(File).to receive(:open).and_yield(file_double)
          allow(Assignment::DetectService).to receive(:call).and_return(
            ServiceActor::Result.to_result(success: true, exception: nil)
          )
        end

        specify do
          perform(submission)

          expect(FileUtils).to have_received(:mkdir_p).with("/app/git-repositories/#{submission.id}")
            .ordered
            .once

          expect(s3_client_double).to have_received(:get_object).with(
            bucket: "test",
            key: an_instance_of(String)
          ).ordered.once
        end
      end
    end

    context "with submission of unknown kind" do
      let(:submission) { Data.define(:of_type).new(of_type: "arxiv".inquiry) }

      specify do
        expect { perform(submission) }.to raise_error(
          ArgumentError, "Unexpected submission type \"arxiv\""
        )
      end
    end
  end
end
