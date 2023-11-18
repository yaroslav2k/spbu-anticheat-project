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
end
