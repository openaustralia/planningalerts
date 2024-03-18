# frozen_string_literal: true

require "spec_helper"

describe AlertMailerHelper do
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
    let(:application) { mock_model(Application, id: 1) }
    let(:base_params) { base_tracking_params }

    describe "#application_url_with_tracking" do
      it "returns the correct url" do
        expect(
          helper.application_url_with_tracking(
            id: application.id
          )
        )
          .to eq application_url(
            base_params.merge(
              id: application.id,
              utm_campaign: "view-application"
            )
          )
      end
    end

    context "when there is a comment" do
      let(:comment) { create(:comment) }

      describe "#comment_url_with_tracking" do
        it "returns the correct url" do
          expect(
            helper.comment_url_with_tracking(
              comment:
            )
          )
            .to eq application_url(
              base_params.merge(
                id: comment.application.id,
                anchor: "comment#{comment.id}",
                utm_campaign: "view-comment"
              )
            )
        end
      end
    end

    describe "#new_comment_url_with_tracking" do
      it {
        expect(
          helper.new_comment_url_with_tracking(
            id: application.id
          )
        )
          .to eq application_url(
            base_params.merge(
              id: application.id,
              utm_campaign: "add-comment",
              anchor: "add-comment"
            )
          )
      }
    end
  end

  describe "#subject" do
    let(:alert) { create(:alert, address: "123 Sample St") }
    let(:application) do
      create(:geocoded_application, address: "Bar Street",
                                    description: "Alterations & additions",
                                    council_reference: "007")
    end
    let(:comment) { create(:comment, application:) }
    let(:comment2) { create(:comment, application:) }

    context "with an application" do
      subject { helper.subject(alert, [application], []) }

      it { is_expected.to eql "1 new planning application near 123 Sample St" }
    end

    context "with a comment" do
      subject { helper.subject(alert, [], [comment]) }

      it { is_expected.to eql "1 new comment on planning applications near 123 Sample St" }
    end

    context "with an application and a comment" do
      subject { helper.subject(alert, [application], [comment]) }

      it { is_expected.to eql "1 new comment and 1 new planning application near 123 Sample St" }
    end
  end
end
