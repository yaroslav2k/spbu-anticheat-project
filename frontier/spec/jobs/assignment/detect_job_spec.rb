# frozen_string_literal: true

RSpec.describe Assignment::DetectJob do
  describe "#perform" do
    def perform(assignment, submission)
      perform_enqueued_jobs only: described_class do
        described_class.perform_later(assignment, submission)
      end
    end

    before do
      allow(Assignment::DetectService).to receive(:call)
    end

    let(:assignment) { create(:assignment) }

    specify do
      perform(assignment, nil)

      expect(Assignment::DetectService).to have_received(:call).with(
        assignment:, submission: nil
      )
    end
  end
end
