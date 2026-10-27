# frozen_string_literal: true

require "spec_helper"

describe CommentsController do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "#per_week" do
    subject(:get_authority_comments_per_week) do
      get(:per_week, params: { authority_id: "blue_mountains", format: :json })
    end

    let!(:authority) { create(:authority, short_name: "Blue Mountains", id: 1) }

    before do
      Timecop.freeze(Time.zone.local(2016, 1, 5))
    end

    after do
      Timecop.return
    end

    it { expect(get_authority_comments_per_week).to be_successful }

    context "when the authority has no applications" do
      it "returns an empty Array as json" do
        get_authority_comments_per_week

        expect(response.parsed_body).to eq([])
      end
    end

    it "returns comments per week for an authority as json" do
      create(
        :geocoded_application,
        authority:,
        date_scraped: Date.new(2015, 12, 24),
        id: 1
      )

      create(:published_comment, application_id: 1, published_at: Date.new(2015, 12, 26))
      create(:published_comment, application_id: 1, published_at: Date.new(2015, 12, 26))
      create(:published_comment, application_id: 1, published_at: Date.new(2015, 12, 26))
      create(:published_comment, application_id: 1, published_at: Date.new(2016, 1, 4))

      get_authority_comments_per_week

      expect(response.parsed_body).to eq(
        [
          ["2015-12-20", 3],
          ["2015-12-27", 0],
          ["2016-01-03", 1]
        ]
      )
    end
  end

  describe "when comments are disabled on the application" do
    let(:application) { create(:geocoded_application, :comments_disabled) }
    let(:user) { create(:confirmed_user) }
    let(:comment_params) { { name: "Jane Ng", text: "Hello", address: "1 Foo St" } }

    before do
      sign_in user
    end

    describe "#create" do
      it "rejects the comment and saves nothing" do
        expect do
          post :create, params: { application_id: application.id, comment: comment_params }
        end.not_to change(Comment, :count)

        expect(response).to have_http_status(:forbidden)
      end

      it "rejects an admin too" do
        user.add_role(:admin)

        expect do
          post :create, params: { application_id: application.id, comment: comment_params }
        end.not_to change(Comment, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "with an existing draft" do
      let!(:draft) { create(:comment, application:, user:) }

      it "does not update it" do
        patch :update, params: { application_id: application.id, id: draft.id, comment: { text: "Changed" } }

        expect(response).to have_http_status(:forbidden)
        expect(draft.reload.text).to eq "a comment"
      end

      it "does not publish or send it" do
        expect do
          post :publish, params: { application_id: application.id, id: draft.id }
        end.not_to(change { ActionMailer::Base.deliveries.count })

        expect(response).to have_http_status(:forbidden)
        expect(draft.reload).not_to be_published
      end
    end
  end
end
