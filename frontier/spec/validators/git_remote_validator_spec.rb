# frozen_string_literal: true

RSpec.describe GitRemoteValidator, type: :validator do
  let(:http_request_successful) { true }

  let(:response_double) { instance_double(HTTParty::Response, success?: http_request_successful) }
  let(:evaluator_double) { instance_double(Proc, call: response_double, :[] => response_double) }

  before do
    stub_const("GitRemoteValidator::HTTP_REQUEST_EVALUATOR", evaluator_double)
  end

  context "without provided options" do
    context "with successful result" do
      it { expect(described_class).to validate("https://github.com/foo/bar") }
    end

    context "with unsuccessful result" do
      let(:http_request_successful) { false }

      specify do
        expect(described_class)
          .to validate("https://github.com/foo/bar")
          .and_report_error(:git_remote_branch_not_found)
      end
    end
  end

  context "with provided `branch` option" do
    specify do
      expect(described_class).to validate("https://github.com/foo/bar", branch: :primary)

      expect(evaluator_double).to have_received(:[]).with("https://github.com/foo/bar/tree/primary")
    end

    context "when is a callable object" do
      specify do
        expect(described_class).to validate("https://github.com/foo/bar", branch: ->(_record) { :feature })

        expect(evaluator_double).to have_received(:[]).with("https://github.com/foo/bar/tree/feature")
      end
    end
  end
end
