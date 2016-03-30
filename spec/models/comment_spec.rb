require 'spec_helper'

describe Comment do
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
          create(:confirmed_comment, created_at: Date.yesterday)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.today)).to eq [] }
    end

    context "when there are no confirmed comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:unconfirmed_comment, created_at: Date.today)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.today)).to eq [] }
    end

    context "when there is a confirmed comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment = create(:confirmed_comment, created_at: Date.today)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.today)).to eq [@comment] }
    end

    context "when there is a confirmed comments on this date and on another date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @todays_comment = create(:confirmed_comment, created_at: Date.today)
          @yesterdays_comment = create(:confirmed_comment, created_at: Date.yesterday)
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.today)).to eq [@todays_comment] }
    end

    context "when there are two confirmed comments on this date with the same email" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment1 = create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
          @comment2 = create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
        end
      end

      it { expect(Comment.visible_with_unique_emails_for_date(Date.today)).to eq [@comment1] }
    end
  end

  describe ".by_first_time_commenters_for_date" do
    context "when there are no comments" do
      it { expect(Comment.by_first_time_commenters_for_date("2015-09-22")).to eq [] }
    end

    context "there is a first time commenter" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment = create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
        end
      end

      it { expect(Comment.by_first_time_commenters_for_date(Date.today)).to eq [@comment] }
    end

    context "when a person has commented on two dates" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @yesterdays_comment = create(:confirmed_comment, created_at: Date.yesterday, email: "foo@example.com")
          @todays_comment = create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
        end
      end

      it "counts them as a first time commenter on the date they first commented" do
        expect(Comment.by_first_time_commenters_for_date(Date.yesterday)).to eq [@yesterdays_comment]
      end

      it "does not count them as a first time commenter on the second date they commented" do
        expect(Comment.by_first_time_commenters_for_date(Date.today)).to eq []
      end
    end
  end

  describe ".by_returning_commenters_for_date" do
    context "when there are no comments" do
      it { expect(Comment.by_returning_commenters_for_date("2015-09-22")).to eq [] }
    end

    context "there is a first time commenter" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
        end
      end

      it { expect(Comment.by_returning_commenters_for_date(Date.today)).to eq [] }
    end

    context "when a person has commented on two dates" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @yesterdays_comment = create(:confirmed_comment, created_at: Date.yesterday, email: "foo@example.com")
          @todays_comment = create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
        end
      end

      it "counts them as a returning commenter on the second date they commented" do
        expect(Comment.by_returning_commenters_for_date(Date.today)).to eq [@todays_comment]
      end

      it "does not count them as a returning commenter on the date they first commented" do
        expect(Comment.by_returning_commenters_for_date(Date.yesterday)).to eq []
      end

      it "the returning count should equal the total count minus new commenters count" do
        returning_count = Comment.by_returning_commenters_for_date(Date.today).to_a.count
        first_time_count = Comment.by_first_time_commenters_for_date(Date.today).to_a.count
        total_count = Comment.visible_with_unique_emails_for_date(Date.today).to_a.count

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

  describe ".fill_confirmed_at_for_existing_confirmed_comments" do
    around do |example|
      VCR.use_cassette('planningalerts') do
        example.run
      end
    end

    it "sets confirmed_at to updated_at for comments that have been confirmed" do
      date = Time.utc(2016, 3, 30, 9, 53, 30).in_time_zone
      create(:confirmed_comment, id: 1, confirmed_at: nil, updated_at: date)

      Comment.fill_confirmed_at_for_existing_confirmed_comments

      expect(Comment.find(1).confirmed_at).to eql date
    end

    it "does nothing to comments that already have a confirmed_at value" do
      old_date = Time.utc(2015, 10, 15, 16, 5, 10).in_time_zone
      new_date = Time.utc(2016, 3, 30, 9, 53, 30).in_time_zone
      create(:confirmed_comment, id: 1, confirmed_at: old_date, updated_at: new_date)

      Comment.fill_confirmed_at_for_existing_confirmed_comments

      expect(Comment.find(1).confirmed_at).to eql old_date
    end

    it "does nothing to comments that have not been confirmed" do
      create(:unconfirmed_comment, id: 1)

      Comment.fill_confirmed_at_for_existing_confirmed_comments

      expect(Comment.find(1).confirmed_at).to be_nil
    end
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
end
