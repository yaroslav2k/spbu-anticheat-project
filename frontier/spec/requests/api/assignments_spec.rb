# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API::Assignment" do
  let(:user) { create(:user, password:) }
  let(:password) { Faker::Number.hexadecimal.to_s }

  let(:course) { create(:course, user:) }
  let!(:assignments) { create_list(:assignment, 2, course:) }

  path "/api/assignments" do
    get "List assignments" do
      tags :assignments

      security [bearer: []]

      let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password}")}" }

      include_examples "API: authorization"

      response 200, "Operation succeeed" do
        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to match_array(assignments.as_json)
        end
      end
    end
  end

  path "/api/assignments/{id}" do
    parameter name: :id, in: :path, type: :string, description: "Assignment ID"

    get "Find assignment" do
      tags :assignments

      security [bearer: []]

      let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password}")}" }
      let(:id) { assignments.first.id }

      include_examples "API: authorization"

      response 200, "Operation succeeed" do
        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq(assignments.first.as_json)
        end
      end

      response 404, "Resource not found" do
        let(:id) { assignments.map(&:id).max.succ }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          expect(response.body).to be_empty
        end
      end
    end
  end
end
