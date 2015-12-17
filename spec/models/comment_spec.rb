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

  describe "#receiver_must_be_selected_if_options_available" do
    let(:comment) { VCR.use_cassette('planningalerts') { build(:comment) } }

    context "when there is no option to send it to a councillor" do
      before { allow(comment).to receive(:has_for_options?).and_return(false) }

      context "and no receiver option is set" do
        before do
          comment.update_attribute(:for_planning_authority, nil)
          comment.update_attribute(:councillor_id, nil)
        end

        it { expect(comment).to be_valid }
      end
    end

    context "when it could be sent to a councillor" do
      before { allow(comment).to receive(:has_for_options?).and_return(true) }

      context "and for_authority has been set true" do
        before { comment.update_attribute(:for_planning_authority, true) }

        context "and no councillor has been selected" do
          before { comment.update_attribute(:councillor_id, nil) }

          it { expect(comment).to be_valid }
        end
      end

      context "and for_authority is not set" do
        before { comment.update_attribute(:for_planning_authority, nil) }

        context "and no councillor has been selected" do
          it "is not valid" do
            expect(comment).to_not be_valid
            expect(comment.errors[:receiver_options])
              .to eq ["You need to select who your message should go to from the list below."]
          end
        end

        context "and a councillor has been selected" do
          before { comment.update_attribute(:councillor_id, create(:councillor).id) }

          it { expect(comment).to be_valid }
        end
      end
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

  describe "#has_for_options?" do
    let(:comment) do
      VCR.use_cassette('planningalerts') do
        create(:comment)
      end
    end

    context "when the writing to councillors feature is not enabled" do
      context "and Default theme is active" do
        before :each do
          comment.update_attribute(:theme, "default")
        end

        context "and there are councillors" do
          it { expect(comment.has_for_options?).to eq false }
        end

        context "and there are not councillors" do
          it { expect(comment.has_for_options?).to eq false }
        end
      end

      context "and the NSW theme is active" do
        before :each do
          comment.update_attribute(:theme, "nsw")
        end

        context "and there are councillors" do
          before do
            create(:councillor, authority: comment.application.authority)
          end

          it { expect(comment.has_for_options?).to eq false }
        end

        context "and there are not councillors" do
          it { expect(comment.has_for_options?).to eq false }
        end
      end
    end

    context "when the writing to councillors feature is enabled" do
      around do |test|
        with_modified_env COUNCILLORS_ENABLED: 'true' do
          test.run
        end
      end

      context "and Default theme is active" do
        before :each do
          comment.update_attribute(:theme, "default")
        end

        context "and there are councillors" do
          before do
            create(:councillor, authority: comment.application.authority)
          end

          it { expect(comment.has_for_options?).to eq true }
        end

        context "and there are not councillors" do
          it { expect(comment.has_for_options?).to eq false }
        end
      end

      context "and the NSW theme is active" do
        before :each do
          comment.update_attribute(:theme, "nsw")
        end

        context "and there are councillors" do
          it { expect(comment.has_for_options?).to eq false }
        end

        context "and there are not councillors" do
          it { expect(comment.has_for_options?).to eq false }
        end
      end
    end
  end

  describe "#for_planning_authority?" do
    let(:comment) do
      VCR.use_cassette('planningalerts') do
        create(:comment)
      end
    end

    context "when it can't be sent to councillors" do
      before { allow(comment).to receive(:has_for_options?).and_return(false) }

      it { expect(comment.for_planning_authority?).to eq true }
    end

    context "when it can be sent to councillors" do
      before { allow(comment).to receive(:has_for_options?).and_return(true) }

      it "defaults to false" do
        expect(comment.for_planning_authority?).to eq false
      end

      context "and when for_planning_authority has been set true" do
        before { comment.update(for_planning_authority: true) }

        it { expect(comment.for_planning_authority?).to eq true }
      end

      context "and when for_planning_authority has set true false" do
        before { comment.update(for_planning_authority: false) }

        it { expect(comment.for_planning_authority?).to eq false }
      end
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

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
