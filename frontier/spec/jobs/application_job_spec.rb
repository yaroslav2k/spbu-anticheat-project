# frozen_string_literal: true

RSpec.describe ApplicationJob do
  describe "#perform" do
    def perform
      described_class.perform_now
    end

    it { expect { perform }.to raise_error(RuntimeError, "Not implemented") }
  end
end
