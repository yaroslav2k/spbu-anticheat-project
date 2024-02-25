# frozen_string_literal: true

require "stringio"

RSpec.describe Admin::AssignmentsController do
  describe "#index" do
    render_views

    let(:user) { create(:user) }

    before { sign_in(user) }

    specify do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe "#report" do
    render_views

    let(:user) { create(:user) }
    let(:course) { create(:course, user:) }
    let!(:assignment) { create(:assignment, course:) }

    let(:manifest) do
      {
        clusters: [
          [
            revision: "revision",
            file_name: "file_name",
            class_name: "class_name",
            function_name: "function_name",
            function_start: "function_start",
            function_end: "function_end"
          ]
        ]
      }
    end

    let(:response_double) { double("response", body: StringIO.new(manifest.to_json)) } # rubocop:disable RSpec/VerifiedDoubles
    let(:s3_client_double) { instance_double(Aws::S3::Client, get_object: response_double) }

    before do
      sign_in(user)

      allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
    end

    specify do
      get :report, params: { id: assignment.id }

      expect(response).to have_http_status(:ok)
    end
  end
end
