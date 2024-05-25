# frozen_string_literal: true

RSpec.describe Admin::CoursesController do
  describe "#index" do
    render_views

    let(:user) { create(:user) }

    before { sign_in(user) }

    specify do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end
end
