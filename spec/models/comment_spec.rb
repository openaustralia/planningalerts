# frozen_string_literal: true

require "spec_helper"

describe Comment do
  it_behaves_like "email_confirmable"

  describe "#confirm!" do
    context "when already confirmed" do
      let(:comment) do
        build(:confirmed_comment)
      end

      it "does not run after_confirm callback" do
        allow(comment).to receive(:after_confirm)
        comment.confirm!
        expect(comment).not_to have_received(:after_confirm)
      end

      it "does not change the confirmed_at time" do
        time_before_confirmed_again = comment.confirmed_at

        comment.confirm!

        expect(comment.confirmed_at).to eql time_before_confirmed_again
      end
    end
  end

  context "when new comment for a planning authority" do
    let(:comment_to_authority) do
      create(:comment)
    end

    it "is not valid without an address" do
      comment_to_authority.address = nil

      expect(comment_to_authority).not_to be_valid
    end

    it "is valid with an address" do
      comment_to_authority.address = "64 Fake St"

      expect(comment_to_authority).to be_valid
    end

    it "handles emojis in the comment text" do
      comment_to_authority.text = "🙏🏼"
      expect { comment_to_authority.save! }.not_to raise_error
    end
  end

  describe "#recipient_display_name" do
    let(:comment) do
      create(:comment)
    end

    context "when the comment application has an authority" do
      before { comment.application.authority.update(full_name: "Marrickville Council") }

      it { expect(comment.recipient_display_name).to eq "Marrickville Council" }
    end

    context "when the comment application is a different authority" do
      before { comment.application.authority.update(full_name: "Other Council") }

      it { expect(comment.recipient_display_name).to eq "Other Council" }
    end
  end
end
