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

    shared_context "with mocked docker client" do
      let(:container_double) { instance_double(Docker::Container) }

      before do
        allow(Docker::Container).to receive(:create).and_return(container_double)
        allow(container_double).to receive_messages(
          start: container_double, attach: container_double, stop: container_double, remove: container_double
        )
      end
    end

    shared_context "with mocked `File.read` method" do
      let(:manifest_data) { { foo: :bar }.to_json }

      before do
        allow(File).to receive(:read).and_return(manifest_data)
      end
    end

    context "with submission of `git` kind" do
      let(:submission) { create(:submission_git) }

      include_context "with mocked docker client"
      include_context "with mocked `File.read` method"

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

          expect(Docker::Container).to have_received(:create).with(
            an_instance_of(Hash)
          ).ordered.once

          expect(File).to have_received(:read).with(
            an_instance_of(String)
          ).ordered.once

          expect(s3_client_double).to have_received(:put_object).with(
            body: manifest_data,
            bucket: "test",
            content_type: "application/json",
            key: an_instance_of(String)
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

      include_context "with mocked docker client"
      include_context "with mocked `File.read` method"

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

          expect(Docker::Container).to have_received(:create).with(
            an_instance_of(Hash)
          ).ordered.once

          expect(s3_client_double).to have_received(:put_object).with(
            body: manifest_data,
            bucket: "test",
            content_type: "application/json",
            key: an_instance_of(String)
          )
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
