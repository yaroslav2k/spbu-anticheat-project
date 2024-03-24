# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API::Courses" do
  let!(:user) { create(:user, password:) }
  let(:password) { Faker::Number.hexadecimal.to_s }

  path "/api/courses" do
    get "List courses" do
      tags :courses

      consumes "application/json"
      security [bearer: []]

      let!(:courses) { create_list(:course, 2, user:) }
      let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password}")}" }

      response 200, "Operation succeeed" do
        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to match_array(courses.as_json)
        end
      end

      response 401, "Unauthorized" do
        let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password.succ}")}" }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to be_empty
        end
      end
    end

    post "Create new course" do
      tags :courses

      consumes "application/json"
      security [bearer: []]

      parameter name: :request_body,
        in: :body, schema: {
                     type: :object,
                     properties: {
                       group: { type: :string },
                       semester: { type: :string },
                       title: { type: :string }
                     }
                   },
        required: %i[group semester title]

      let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password}")}" }

      response 201, "Course created" do
        let(:request_body) do
          { group: "foobar", semester: "spring", title: "course-1" }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          expect(response.body).to be_empty
        end
      end

      response 401, "Unauthorized" do
        let(:request_body) do
          { group: "foobar", semester: "spring", title: "course-1" }
        end
        let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password.succ}")}" }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to be_empty
        end
      end

      response 422, "Invalid request payload" do
        let(:request_body) do
          { group: "foobar", semester: "весна", title: "course-1" }
        end

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to be_empty
        end
      end
    end
  end
end
