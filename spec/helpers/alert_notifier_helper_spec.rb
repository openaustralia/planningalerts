# frozen_string_literal: true

require "spec_helper"

describe AlertNotifierHelper do
  describe "#capitalise_initial_character(text)" do
    it { expect(helper.capitalise_initial_character("foo bar")).to eq "Foo bar" }
    it { expect(helper.capitalise_initial_character("foo Bar")).to eq "Foo Bar" }
  end

  describe "#base_tracking_params" do
    it {
      expect(helper.base_tracking_params)
        .to eq(utm_source: "alerts", utm_medium: "email")
    }
  end

  context "when application and theme are set" do
    before :each do
      @application = mock_model(Application, id: 1)
      @base_params = base_tracking_params
    end

    describe "#application_url_with_tracking" do
      it "returns the correct url" do
        expect(
          helper.application_url_with_tracking(
            id: @application.id
          )
        )
          .to eq application_url(
            @base_params.merge(
              id: @application.id,
              utm_campaign: "view-application"
            )
          )
      end
    end

    context "and there is a comment" do
      before :each do
        @comment = create(:comment, application: @application)
      end

      describe "#comment_url_with_tracking" do
        it "returns the correct url" do
          expect(
            helper.comment_url_with_tracking(
              comment: @comment
            )
          )
            .to eq application_url(
              @base_params.merge(
                id: @comment.application.id,
                anchor: "comment#{@comment.id}",
                utm_campaign: "view-comment"
              )
            )
        end
      end
    end

    describe "#reply_url_with_tracking" do
      let(:reply) do
        create(:reply, id: 5)
      end

      it "returns the correct url" do
        expect(
          helper.reply_url_with_tracking(
            reply: reply
          )
        )
          .to eq application_url(
            @base_params.merge(
              id: reply.comment.application.id,
              anchor: "reply5",
              utm_campaign: "view-reply"
            )
          )
      end
    end

    describe "#new_comment_url_with_tracking" do
      it {
        expect(
          helper.new_comment_url_with_tracking(
            id: @application.id
          )
        )
          .to eq application_url(
            @base_params.merge(
              id: @application.id,
              utm_campaign: "add-comment",
              anchor: "add-comment"
            )
          )
      }
    end
  end

  describe "#new_donation_url_with_tracking" do
    before :each do
      @alert = create(:alert)
    end

    context "when the theme is \"default\"" do
      before :each do
        @base_params_plus_email_and_campaign = base_tracking_params.merge(
          email: @alert.email,
          utm_campaign: "donate-from-alert"
        )
      end

      subject { helper.new_donation_url_with_tracking }

      it { is_expected.to eq new_donation_url(@base_params_plus_email_and_campaign) }
    end
  end

  describe "#subject" do
    let(:alert) { create(:alert, address: "123 Sample St") }
    let(:application) do
      mock_model(Application, address: "Bar Street",
                              description: "Alterations & additions",
                              council_reference: "007",
                              location: double(lat: 1.0, lng: 2.0))
    end
    let(:comment) { create(:comment, application: application) }
    let(:comment2) { create(:comment, application: application) }
    let(:reply) { create(:reply, comment: comment) }

    context "with an application" do
      subject { helper.subject(alert, [application], [], []) }
      it { is_expected.to eql "1 new planning application near 123 Sample St" }
    end

    context "with a comment" do
      subject { helper.subject(alert, [], [comment], []) }
      it { is_expected.to eql "1 new comment on planning applications near 123 Sample St" }
    end

    context "with a reply" do
      subject { helper.subject(alert, [], [], [reply]) }
      it { is_expected.to eql "1 new reply on planning applications near 123 Sample St" }
    end

    context "with an application and a comment" do
      subject { helper.subject(alert, [application], [comment], []) }
      it { is_expected.to eql "1 new comment and 1 new planning application near 123 Sample St" }
    end

    context "with an application and a reply" do
      subject { helper.subject(alert, [application], [], [reply]) }
      it { is_expected.to eql "1 new reply and 1 new planning application near 123 Sample St" }
    end

    context "with an application, a comment, and a reply" do
      subject { helper.subject(alert, [application], [comment], [reply]) }
      it { is_expected.to eql "1 new comment, 1 new reply and 1 new planning application near 123 Sample St" }
    end
  end
end
