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

    let!(:upload_1) { create(:upload) }
    let!(:upload_2) { create(:upload) }

    let(:manifest) do
      {
        result: [
          {
            code_fragments: [
              {
                identifier: "nicadclones/data/data/#{upload_1.id}.py",
                line_start: 1,
                line_end: 95
              },
              {
                identifier: "nicadclones/data/data/#{upload_1.id}.py",
                line_start: 1,
                line_end: 102
              }
            ],
            similarity: 72
          }
        ],
        algorithm: { name: "nicad" }
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
