# frozen_string_literal: true

# == Schema Information
#
# Table name: submissions
#
#  id            :uuid             not null, primary key
#  author_group  :string           not null
#  author_name   :string           not null
#  data          :jsonb            not null
#  status        :string           default("created"), not null
#  type          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :uuid
#
# Indexes
#
#  index_submissions_on_assignment_id  (assignment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignment_id => assignments.id)
#
RSpec.describe Submission do
  before do
    response_double = instance_double(HTTParty::Response, success?: true)
    evaluator_double = instance_double(Proc, call: response_double, :[] => response_double)
    stub_const("GitRemoteValidator::HTTP_REQUEST_EVALUATOR", evaluator_double)
  end

  describe "enumerations" do
    subject(:submission) { build(:submission) }

    specify do
      expect(submission).to enumerize(:status)
        .in(%w[created completed failed])
        .with_default("created")
        .with_scope(:shallow)
        .with_predicates(true)
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:assignment).counter_cache }

    it { is_expected.to have_one(:telegram_form).dependent(:destroy) }
  end

  describe "instance methods" do
    describe "#to_s" do
      context "with `git` submission type" do
        subject(:submission) { create(:submission_git) }

        its(:to_s) do
          is_expected.to eq("#{submission.url} (#{submission.branch}) — #{submission.author_name} (#{submission.author_group})")
        end
      end

      context "with `files_group` submission type" do
        subject(:submission) { create(:submission_files_group) }

        its(:to_s) { is_expected.to eq("File (#{submission.author_name})") }
      end
    end

    describe "#source_url" do
      subject(:submission) { create(:submission_files_group) }

      let(:assignment) { submission.assignment }
      let(:course) { assignment.course }

      its(:source_url) do
        is_expected.to eq(
          "https://127.0.0.1/storage/test/courses/#{course.id}/assignments/#{assignment.id}/submissions/#{submission.id}/manifest.json"
        )
      end
    end
  end
end
