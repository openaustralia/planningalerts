# frozen_string_literal: true

require "spec_helper"

describe Comment do
  it_behaves_like "email_confirmable"

  describe "#confirm!" do
    context "when already confirmed" do
      let(:comment) do
        build(:confirmed_comment)
      end

      it "should not run after_confirm callback" do
        expect(comment).to_not receive(:after_confirm)
        comment.confirm!
      end

      it "should not change the confirmed_at time" do
        time_before_confirmed_again = comment.confirmed_at

        comment.confirm!

        expect(comment.confirmed_at).to eql time_before_confirmed_again
      end
    end
  end

  context "new comment for a planning authority" do
    let(:comment_to_authority) do
      create(:comment_to_authority)
    end

    it "is not valid without an address" do
      comment_to_authority.address = nil

      expect(comment_to_authority).to_not be_valid
    end

    it "is valid with an address" do
      comment_to_authority.address = "64 Fake St"

      expect(comment_to_authority).to be_valid
    end
  end

  context "new comment for a councillor" do
    let(:comment_to_councillor) do
      create(:comment_to_councillor)
    end

    it "is valid without an address" do
      comment_to_councillor.address = nil

      expect(comment_to_councillor).to be_valid
    end

    it "is valid with an address" do
      comment_to_councillor.address = "64 Fake St"

      expect(comment_to_councillor).to be_valid
    end
  end

  context "to a planning authority" do
    let(:comment_to_authority) do
      create(:comment_to_authority)
    end

    it { expect(comment_to_authority.to_councillor?).to eq false }
    it { expect(comment_to_authority.awaiting_councillor_reply?).to eq false }
  end

  context "to a councillor" do
    let(:comment_to_councillor) do
      create(:comment_to_councillor)
    end

    it { expect(comment_to_councillor.to_councillor?).to eq true }
    it { expect(comment_to_councillor.awaiting_councillor_reply?).to eq true }
  end

  context "to a councillor and has no reply" do
    let(:comment_with_reply) do
      create(:reply).comment
    end

    it { expect(comment_with_reply.awaiting_councillor_reply?).to eq false }
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

    context "when the comment is a message to a councillor" do
      before { comment.councillor = create(:councillor, name: "Louise Councillor") }

      it { expect(comment.recipient_display_name).to eq "local councillor Louise Councillor" }
    end
  end

  describe "#create_replies_from_writeit!" do
    around do |test|
      with_modified_env(writeit_config_variables) do
        test.run
      end
    end

    let(:comment) do
      create(:comment_to_councillor, writeit_message_id: 1234)
    end

    it "fetches answers from WriteIt, creates replies and returns them" do
      VCR.use_cassette("writeit") do
        comment.create_replies_from_writeit!
      end

      expect(comment.replies.count).to eql 1
      expect(comment.replies.first.text).to eql "I agree, thanks for your comment"
      expect(comment.replies.first.writeit_id).to eql 567
      expect(comment.replies.first.councillor).to eql comment.councillor
      expect(comment.replies.first.received_at).to eql Time.utc(2016, 4, 4, 6, 58, 38)
    end

    it "returns an empty Array if all the replies on WriteIt have already been added" do
      VCR.use_cassette("writeit") do
        create(:reply, comment: comment, writeit_id: 567)

        expect(comment.create_replies_from_writeit!).to be_empty
      end
    end

    it "does nothing if the comment has no writeit_message_id" do
      VCR.use_cassette("writeit") do
        expect(create(:comment).create_replies_from_writeit!).to be_falsey
      end
    end

    it "returns an empty Array if there are no replies on WriteIt" do
      skip
    end

    context "when the councillor is not current" do
      before do
        comment.councillor.update(current: false)
      end

      it "still loads the reply" do
        VCR.use_cassette("writeit") do
          comment.create_replies_from_writeit!
        end

        expect(comment.replies.first.text).to eql "I agree, thanks for your comment"
        expect(comment.replies.first.councillor).to eql comment.councillor
      end
    end
  end

  describe "#to_councillor?" do
    let(:comment) { build(:comment) }

    it "should be false when there's no associated councillor" do
      expect(comment.to_councillor?).to be false
    end

    it "should be true when there's an associated councillor" do
      comment.councillor = build(:councillor)
      expect(comment.to_councillor?).to be true
    end
  end
end
