# frozen_string_literal: true

require "spec_helper"

describe CuttlefishController do
  context "when has a webhook key" do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("CUTTLEFISH_WEBHOOK_KEY").and_return("abc123")
      allow(NotifySlackCommentDeliveryService).to receive(:call)
    end

    it "does not allow an incorrect webhook key" do
      post :event, params: { key: "wrong" }, format: :json
      expect(response).to have_http_status(:forbidden)
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "allows a correct webhook key" do
      post :event, params: { key: "abc123" }, format: :json
      expect(response).to have_http_status(:ok)
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "accepts a test event but do nothing" do
      post :event, params: { key: "abc123", test_event: {} }, format: :json
      expect(response).to have_http_status(:ok)
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "accepts a delivery event for an alert email and record a succesful delivery" do
      alert = create(:alert, id: 123)
      params = {
        key: "abc123",
        delivery_event: {
          time: "2020-08-27T02:10:17.000Z",
          dsn: "2.0.0",
          status: "delivered",
          extended_status: "sent (250 Message accepted)",
          email: {
            id: 123,
            message_id: "ABC@DEF.foo.com",
            from: "matthew@oaf.org.au",
            to: "joy@smart-unlimited.com",
            subject: "This is a test email from Cuttlefish",
            created_at: "2020-08-27T02:10:17.579Z",
            meta_values: {
              "alert-id": "123"
            }
          }
        }
      }

      post :event, params: params, format: :json
      expect(response).to have_http_status(:ok)
      alert.reload
      expect(alert.last_delivered_at).to eq "2020-08-27T02:10:17.000Z"
      expect(alert.last_delivered_successfully).to be true
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "accepts a delivery event for an alert email and do nothing" do
      alert = create(:alert, id: 123)
      params = {
        key: "abc123",
        delivery_event: {
          time: "2020-08-27T02:10:17.000Z",
          dsn: "2.0.0",
          status: "soft_bounce",
          extended_status: "soft bounce message",
          email: {
            id: 123,
            message_id: "ABC@DEF.foo.com",
            from: "matthew@oaf.org.au",
            to: "joy@smart-unlimited.com",
            subject: "This is a test email from Cuttlefish",
            created_at: "2020-08-27T02:10:17.579Z",
            meta_values: {
              "alert-id": "123"
            }
          }
        }
      }

      post :event, params: params, format: :json
      expect(response).to have_http_status(:ok)
      alert.reload
      expect(alert.last_delivered_at).to be_nil
      expect(alert.last_delivered_successfully).to be_nil
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "accepts a delivery event for an alert email and record a failed delivery" do
      alert = create(:alert, id: 123)
      params = {
        key: "abc123",
        delivery_event: {
          time: "2020-08-27T02:10:17.000Z",
          dsn: "2.0.0",
          status: "hard_bounce",
          extended_status: "hard bounce message",
          email: {
            id: 123,
            message_id: "ABC@DEF.foo.com",
            from: "matthew@oaf.org.au",
            to: "joy@smart-unlimited.com",
            subject: "This is a test email from Cuttlefish",
            created_at: "2020-08-27T02:10:17.579Z",
            meta_values: {
              "alert-id": "123"
            }
          }
        }
      }

      post :event, params: params, format: :json
      expect(response).to have_http_status(:ok)
      alert.reload
      expect(alert.last_delivered_at).to eq "2020-08-27T02:10:17.000Z"
      expect(alert.last_delivered_successfully).to be false
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "accepts a succesful delivery event for a comment email" do
      comment = create(:comment, id: 12)
      params = {
        key: "abc123",
        delivery_event: {
          time: "2020-08-27T02:10:17.000Z",
          dsn: "2.0.0",
          status: "delivered",
          extended_status: "sent (250 Message accepted)",
          email: {
            id: 123,
            message_id: "ABC@DEF.foo.com",
            from: "matthew@oaf.org.au",
            to: "joy@smart-unlimited.com",
            subject: "This is a test email from Cuttlefish",
            created_at: "2020-08-27T02:10:17.579Z",
            meta_values: {
              "comment-id": "12"
            }
          }
        }
      }
      post :event, params: params, format: :json
      expect(response).to have_http_status(:ok)
      comment.reload
      expect(comment.last_delivered_at).to eq "2020-08-27T02:10:17.000Z"
      expect(comment.last_delivered_successfully).to be true
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end

    it "accepts a hard bounce delivery event for a comment email and do something" do
      comment = create(:comment, id: 12)

      params = {
        key: "abc123",
        delivery_event: {
          time: "2020-08-27T02:10:17.000Z",
          dsn: "2.0.0",
          status: "hard_bounce",
          extended_status: "hard bounce",
          email: {
            id: 123,
            message_id: "ABC@DEF.foo.com",
            from: "matthew@oaf.org.au",
            to: "joy@smart-unlimited.com",
            subject: "This is a test email from Cuttlefish",
            created_at: "2020-08-27T02:10:17.579Z",
            meta_values: {
              "comment-id": "12"
            }
          }
        }
      }
      post :event, params: params, format: :json
      expect(response).to have_http_status(:ok)
      comment.reload
      expect(comment.last_delivered_at).to eq "2020-08-27T02:10:17.000Z"
      expect(comment.last_delivered_successfully).to be false
      expect(NotifySlackCommentDeliveryService).to have_received(:call).with(
        comment: comment,
        to: "joy@smart-unlimited.com",
        status: "hard_bounce",
        extended_status: "hard bounce",
        email_id: 123
      )
    end

    it "accepts a soft bounce delivery event for a comment email and do something" do
      comment = create(:comment, id: 12)

      params = {
        key: "abc123",
        delivery_event: {
          time: "2020-08-27T02:10:17.000Z",
          dsn: "2.0.0",
          status: "soft_bounce",
          extended_status: "soft bounce",
          email: {
            id: 123,
            message_id: "ABC@DEF.foo.com",
            from: "matthew@oaf.org.au",
            to: "joy@smart-unlimited.com",
            subject: "This is a test email from Cuttlefish",
            created_at: "2020-08-27T02:10:17.579Z",
            meta_values: {
              "comment-id": "12"
            }
          }
        }
      }
      post :event, params: params, format: :json
      expect(response).to have_http_status(:ok)
      comment.reload
      expect(comment.last_delivered_at).to be_nil
      expect(comment.last_delivered_successfully).to be_nil
      expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
    end
  end
end
