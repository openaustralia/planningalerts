# frozen_string_literal: true

require "spec_helper"

describe AltchaSolution do
  let(:expires_at) { 10.minutes.from_now }

  describe ".record!" do
    it "records a signature it hasn't seen" do
      expect(described_class.record!(signature: "abc", expires_at:)).to be true
      expect(described_class.count).to eq 1
    end

    it "returns false for a signature it has already recorded" do
      described_class.record!(signature: "abc", expires_at:)

      expect(described_class.record!(signature: "abc", expires_at:)).to be false
    end

    it "doesn't record the same signature twice" do
      2.times { described_class.record!(signature: "abc", expires_at:) }

      expect(described_class.count).to eq 1
    end

    # The unique violation happens inside a savepoint for this reason. Without
    # it the example's own transaction would be aborted and every query after
    # the duplicate would fail.
    it "leaves the surrounding transaction usable after a duplicate" do
      described_class.record!(signature: "abc", expires_at:)
      described_class.record!(signature: "abc", expires_at:)

      expect(described_class.count).to eq 1
      expect(described_class.record!(signature: "def", expires_at:)).to be true
    end

    it "relies on the database rather than a read, so two requests can't both win" do
      expect { described_class.create!(signature: "abc", expires_at:) }
        .to change(described_class, :count).by(1)
      expect { described_class.create!(signature: "abc", expires_at:) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
