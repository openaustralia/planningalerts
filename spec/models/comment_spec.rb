require 'spec_helper'

describe Comment do
  describe ".comments_with_unique_emails_for_date" do
    context "when there are no comments" do
      it { expect(Comment.comments_with_unique_emails_for_date("2015-09-22")).to eq [] }
    end

    context "when there are no confirmed comments" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: false)
        end
      end

      it { expect(Comment.comments_with_unique_emails_for_date("2015-09-22")).to eq [] }
    end

    context "when there are no comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: true, created_at: Date.yesterday)
        end
      end

      it { expect(Comment.comments_with_unique_emails_for_date(Date.today)).to eq [] }
    end

    context "when there are no confirmed comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: false, created_at: Date.today)
        end
      end

      it { expect(Comment.comments_with_unique_emails_for_date(Date.today)).to eq [] }
    end

    context "when there is a confirmed comments on this date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment = create(:comment, confirmed: true, created_at: Date.today)
        end
      end

      it { expect(Comment.comments_with_unique_emails_for_date(Date.today)).to eq [@comment] }
    end

    context "when there is a confirmed comments on this date and on another date" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @todays_comment = create(:comment, confirmed: true, created_at: Date.today)
          @yesterdays_comment = create(:comment, confirmed: true, created_at: Date.yesterday)
        end
      end

      it { expect(Comment.comments_with_unique_emails_for_date(Date.today)).to eq [@todays_comment] }
    end

    context "when there are two confirmed comments on this date with the same email" do
      before :each do
        VCR.use_cassette('planningalerts') do
          @comment1 = create(:comment, confirmed: true, created_at: Date.today, email: "foo@example.com")
          @comment2 = create(:comment, confirmed: true, created_at: Date.today, email: "foo@example.com")
        end
      end

      it { expect(Comment.comments_with_unique_emails_for_date(Date.today)).to eq [@comment1] }
    end
  end

  describe ".count_of_first_time_commenters_for_date" do
    context "when there are no comments" do
      it { expect(Comment.count_of_first_time_commenters_for_date("2015-09-22")).to eq 0 }
    end

    context "there is a first time commenter" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: true, created_at: Date.today, email: "foo@example.com")
        end
      end

      it { expect(Comment.count_of_first_time_commenters_for_date(Date.today)).to eq 1 }
    end

    context "when a person has commented on two dates" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: true, created_at: Date.yesterday, email: "foo@example.com")
          create(:comment, confirmed: true, created_at: Date.today, email: "foo@example.com")
        end
      end

      it "counts them as a first time commenter on the date they first commented" do
        expect(Comment.count_of_first_time_commenters_for_date(Date.yesterday)).to eq 1
      end

      it "does not count them as a first time commenter on the second date they commented" do
        expect(Comment.count_of_first_time_commenters_for_date(Date.today)).to eq 0
      end
    end
  end

  describe ".count_of_returning_commenters_for_date" do
    context "when there are no comments" do
      it { expect(Comment.count_of_returning_commenters_for_date("2015-09-22")).to eq 0 }
    end

    context "there is a first time commenter" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: true, created_at: Date.today, email: "foo@example.com")
        end
      end

      it { expect(Comment.count_of_returning_commenters_for_date(Date.today)).to eq 0 }
    end

    context "when a person has commented on two dates" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(:comment, confirmed: true, created_at: Date.yesterday, email: "foo@example.com")
          create(:comment, confirmed: true, created_at: Date.today, email: "foo@example.com")
        end
      end

      it "counts them as a returning commenter on the second date they commented" do
        expect(Comment.count_of_returning_commenters_for_date(Date.today)).to eq 1
      end

      it "does not count them as a returning commenter on the date they first commented" do
        expect(Comment.count_of_returning_commenters_for_date(Date.yesterday)).to eq 0
      end

      it "the returning count should be the total count minus new commenters count" do
        returning_count = Comment.count_of_returning_commenters_for_date(Date.today)
        first_time_count = Comment.count_of_first_time_commenters_for_date(Date.today)
        total_count = Comment.comments_with_unique_emails_for_date(Date.today).count
        expect(returning_count).to eq total_count - first_time_count
      end
    end
  end
end
