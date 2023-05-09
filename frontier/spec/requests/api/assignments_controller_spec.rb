# frozen_string_literal: true

RSpec.describe API::AssignmentsController do
  describe "#create" do
    def perform(params = {})
      post "/api/assignments", params: params, headers: { "Authorization" => "Bearer #{access_token}" }
    end

    let(:credentials_access_token) { "secret" }
    let(:access_token) { credentials_access_token }

    before do
      allow(Rails.application.credentials).to receive(:api).and_return(
        { access_token: credentials_access_token }
      )
    end

    context "with unauthorized request" do
      let(:access_token) { nil }

      specify do
        perform

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid request parameters" do
      let(:params) do
        {}
      end

      it "responds with HTTP 422 Unprocessable Entity", :aggregate_failures do
        perform(params)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq(
          "error" => { "url" => "blank" }
        )
      end
    end

    context "with valid request" do
      let(:access_token) { credentials_access_token }
      let(:params) do
        { url: "https://github.com/foobar" }
      end

      it "responds with HTTP 202 Accepted" do
        perform(params)

        expect(response).to have_http_status(:accepted)
      end
    end
  end
end
