# frozen_string_literal: true

RSpec.shared_examples "API: authorization" do # rubocop:disable RSpec/SharedContext
  response 401, "Unauthorized" do
    let(:Authorization) { "Basic #{Base64.strict_encode64("#{user.username}:#{password.succ}")}" }

    run_test! do |response|
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to be_empty
    end
  end
end
