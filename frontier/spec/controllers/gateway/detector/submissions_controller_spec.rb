# frozen_string_literal: true

RSpec.describe Gateway::Detector::SubmissionsController do
  describe "#update" do
    let(:submission) { create(:submission_git, status: :created) }

    let(:token) { Frontier.config.detector_config.webhook_access_token }

    def perform(id, status:, token:)
      request.headers["authorization"] = "Token #{token}"

      put :update, params: { id:, submission: { status: } }
    end

    specify do
      perform(submission.id, status: :completed, token:)

      expect(response).to have_http_status(:no_content)
    end

    specify do
      expect { perform(submission.id, status: :completed, token:) }
        .to change { submission.reload.status }.from("created").to("completed")
    end
  end
end
