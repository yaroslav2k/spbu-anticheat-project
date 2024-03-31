require "swagger_helper"

RSpec.describe "API::Statuses" do
  path "/api/status" do
    get "Get current status" do
      tags :statuses

      response 204, "Application healthy" do
        run_test! do |response|
          expect(response.body).to be_empty
        end
      end
    end
  end
end
