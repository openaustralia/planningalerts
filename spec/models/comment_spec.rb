require 'spec_helper'

describe Comment do
  it_behaves_like "email_confirmable"

  describe "#confirm!" do
    context "when already confirmed" do
      let(:comment) do
        VCR.use_cassette('planningalerts') { build(:confirmed_comment) }
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

  describe ".visible_with_unique_emails_for_date" do
    context "when there are no comments" do
      it { expect(Comment.visible_with_unique_emails_for_date("2015-09-22")).to eq [] }
    end

    context "when there are no confirmed comments" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:unconfirmed_comment)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date("2015-09-22")).to eq [] }
    end

    context "when there are no comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:confirmed_comment, confirmed_at: Date.yesterday)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.current)).to eq [] }
    end

    context "when there are no confirmed comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:unconfirmed_comment, created_at: Date.current)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.current)).to eq [] }
    end

    context "when there is a confirmed comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment = create(:confirmed_comment, confirmed_at: Date.current)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.current)).to eq [@comment] }
    end

    context "when there is a confirmed comments on this date and on another date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @todays_comment = create(:confirmed_comment, confirmed_at: Date.current)
          @yesterdays_comment = create(:confirmed_comment, confirmed_at: Date.yesterday)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.current)).to eq [@todays_comment] }
    end

    context "when there are two confirmed comments on this date with the same email" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment1 = create(:confirmed_comment, confirmed_at: Date.current, email: "foo@example.com")
          @comment2 = create(:confirmed_comment, confirmed_at: Date.current, email: "foo@example.com")
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.current)).to eq [@comment1] }
    end
  end

  describe ".by_first_time_commenters_for_date" do
    context "when there are no comments" do
      it { expect(Comment.by_first_time_commenters_for_date("2015-09-22")).to eq [] }
    end

    context "there is a first time commenter" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment = create(:confirmed_comment, confirmed_at: Date.current, email: "foo@example.com")
        end
      end

      it { expect(Comment.by_first_time_commenters_for_date(Date.current)).to eq [@comment] }
    end

    context "when a person has commented on two dates" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @yesterdays_comment = create(:confirmed_comment, confirmed_at: Date.yesterday, email: "foo@example.com")
          @todays_comment = create(:confirmed_comment, confirmed_at: Date.current, email: "foo@example.com")
        end
      end

      it "counts them as a first time commenter on the date they first commented" do
        expect(Comment.by_first_time_commenters_for_date(Date.yesterday)).to eq [@yesterdays_comment]
      end

      it "does not count them as a first time commenter on the second date they commented" do
        expect(Comment.by_first_time_commenters_for_date(Date.current)).to eq []
      end
    end
  end

  describe ".by_returning_commenters_for_date" do
    context "when there are no comments" do
      it { expect(Comment.by_returning_commenters_for_date("2015-09-22")).to eq [] }
    end

    context "when there is a first time commenter" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:confirmed_comment, confirmed_at: Date.current, email: "foo@example.com")
        end
      end

      it { expect(Comment.by_returning_commenters_for_date(Date.current)).to eq [] }
    end

    context "when a person has commented on two dates" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @yesterdays_comment = create(:confirmed_comment, confirmed_at: Date.yesterday, email: "foo@example.com")
          @todays_comment = create(:confirmed_comment, confirmed_at: Date.current, email: "foo@example.com")
        end
      end

      it "counts them as a returning commenter on the second date they commented" do
        expect(Comment.by_returning_commenters_for_date(Date.current)).to eq [@todays_comment]
      end

      it "does not count them as a returning commenter on the date they first commented" do
        expect(Comment.by_returning_commenters_for_date(Date.yesterday)).to eq []
      end

      it "the returning count should equal the total count minus new commenters count" do
        returning_count = Comment.by_returning_commenters_for_date(Date.current).to_a.count
        first_time_count = Comment.by_first_time_commenters_for_date(Date.current).to_a.count
        total_count = Comment.visible_with_unique_emails_for_date(Date.current).to_a.count

        expect(returning_count).to eq(total_count - first_time_count)
      end
    end
  end

  context "new comment for a planning authority" do
    let(:comment_to_authority) do
      VCR.use_cassette('planningalerts') do
        create(:comment_to_authority)
      end
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
      VCR.use_cassette('planningalerts') do
        create(:comment_to_councillor)
      end
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
      VCR.use_cassette('planningalerts') do
        create(:comment_to_authority)
      end
    end

    it { expect(comment_to_authority.to_councillor?).to eq false }
    it { expect(comment_to_authority.awaiting_councillor_reply?).to eq false }
  end

  context "to a councillor" do
    let(:comment_to_councillor) do
      VCR.use_cassette('planningalerts') do
        create(:comment_to_councillor)
      end
    end

    it { expect(comment_to_councillor.to_councillor?).to eq true }
    it { expect(comment_to_councillor.awaiting_councillor_reply?).to eq true }
  end

  context "to a councillor and has no reply" do
    let(:comment_with_reply) do
      VCR.use_cassette('planningalerts') do
        create(:reply).comment
      end
    end

    it { expect(comment_with_reply.awaiting_councillor_reply?).to eq false }
  end

  describe "#recipient_display_name" do
    let(:comment) do
      VCR.use_cassette('planningalerts') do
        create(:comment)
      end
    end

    context "when the comment application has an authority" do
      before { comment.application.authority.update_attribute(:full_name, "Marrickville Council") }

      it { expect(comment.recipient_display_name).to eq "Marrickville Council" }
    end

    context "when the comment application is a different authority" do
      before { comment.application.authority.update_attribute(:full_name, "Other Council") }

      it { expect(comment.recipient_display_name).to eq "Other Council" }
    end

    context "when the comment is a message to a councillor" do
      before { comment.councillor = create(:councillor, name: "Louise Councillor")}

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
      VCR.use_cassette('planningalerts') do
        comment.create_replies_from_writeit!
      end

      expect(comment.replies.count).to eql 1
      expect(comment.replies.first.text).to eql "I agree, thanks for your comment"
      expect(comment.replies.first.writeit_id).to eql 567
      expect(comment.replies.first.councillor).to eql comment.councillor
      expect(comment.replies.first.received_at).to eql Time.utc(2016, 4, 4, 6, 58, 38)
    end

    it "returns an empty Array if all the replies on WriteIt have already been added" do
      VCR.use_cassette('planningalerts') do
        create(:reply, comment: comment, writeit_id: 567)

        expect(comment.create_replies_from_writeit!).to be_empty
      end
    end

    it "does nothing if the comment has no writeit_message_id" do
      VCR.use_cassette('planningalerts') do
        expect(create(:comment).create_replies_from_writeit!).to be_falsey
      end
    end

    it "returns an empty Array if there are no replies on WriteIt" do
      skip
    end

    context "when the councillor is not current" do
      before do
        VCR.use_cassette('planningalerts') do
          comment.councillor.update(current: false)
        end
      end

      it "still loads the reply" do
        VCR.use_cassette('planningalerts') do
          comment.create_replies_from_writeit!
        end

        expect(comment.replies.first.text).to eql "I agree, thanks for your comment"
        expect(comment.replies.first.councillor).to eql comment.councillor
      end
    end
  end

  describe "#to_councillor?" do
    let(:comment) { VCR.use_cassette('planningalerts') { build(:comment) } }

    it "should be false when there's no associated councillor" do
      expect(comment.to_councillor?).to be false
    end

    it "should be true when there's an associated councillor" do
      comment.councillor = build(:councillor)
      expect(comment.to_councillor?).to be true
    end
  end
end
