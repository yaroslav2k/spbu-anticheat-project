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

  describe "#prolongate" do
    render_views

    def perform(course)
      post :prolongate, params: { id: course.id }
    end

    context "with fresh course" do
      let(:user) { create(:user) }
      let!(:course) { create(:course, user:, year: Time.zone.now.year, semester: Utilities::DateTime.current_semester) }

      before { sign_in(user) }

      specify do
        perform(course)

        expect(response).to have_http_status(:found)
      end

      it { expect { perform(course) }.to not_change(Course, :count) }
    end

    context "with outdated course" do
      let(:user) { create(:user) }
      let!(:course) { create(:course, user:, year: Time.zone.now.year - 1) }

      before { sign_in(user) }

      specify do
        perform(course)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("http://test.host/")

        expect(user.courses.where.not(id: course.id).sole).to have_attributes(
          year: Time.zone.now.year,
          semester: Utilities::DateTime.current_semester.to_s,
          user:
        )
      end

      it { expect { perform(course) }.to change(Course, :count).by(1) }
    end
  end
end
