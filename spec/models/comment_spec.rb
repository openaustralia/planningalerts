# frozen_string_literal: true

require "spec_helper"

describe Comment do
  describe "confirm_id" do
    let(:object) do
      VCR.use_cassette("planningalerts") { create(:comment) }
    end

    it "is a string" do
      expect(object.confirm_id).to be_instance_of(String)
    end

    it "is not the same for two different objects" do
      another_object = VCR.use_cassette("planningalerts") do
        create(:comment)
      end

      expect(object.confirm_id).not_to eq another_object.confirm_id
    end

    it "only includes hex characters and is exactly twenty characters long" do
      expect(object.confirm_id).to match(/^[0-9a-f]{20}$/)
    end
  end

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
    let(:comment_to_authority) { create(:comment) }
    let(:application) { create(:application) }
    let(:user) { create(:user) }

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

    context "with unpreviewed comments" do
      it "is valid to have one comment on an application for a particular user" do
        comment = build(:comment, application:, user:, previewed: false)
        expect(comment).to be_valid
      end

      it "is not valid to have more than one comment on an application for a particular user" do
        pending "because we haven't implemented the validation yet"
        create(:comment, application:, user:, previewed: false)
        comment = build(:comment, application:, user:, previewed: false)
        expect(comment).not_to be_valid
      end

      it "is valid to have more than one comment on an application from different users" do
        create(:comment, application:, user: create(:user), previewed: false)
        comment = build(:comment, application:, user: create(:user), previewed: false)
        expect(comment).to be_valid
      end

      it "is valid for a user to have comments on more than one application" do
        create(:comment, application: create(:application), user:, previewed: false)
        comment = build(:comment, application: create(:application), user:, previewed: false)
        expect(comment).to be_valid
      end
    end

    it "is valid to have more than one previewed comment on an application for a user" do
      create(:comment, application:, user:, previewed: true)
      comment = build(:comment, application:, user:, previewed: true)
      expect(comment).to be_valid
    end
  end
end
