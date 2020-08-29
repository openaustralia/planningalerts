# frozen_string_literal: true

require "spec_helper"

describe CuttlefishController do
  context "has a webhook key" do
    before { expect(ENV).to receive(:[]).with("CUTTLEFISH_WEBHOOK_KEY").and_return("abc123") }

    it "should not allow an incorrect webhook key" do
      expect(NotifySlackCommentDeliveryService).to_not receive(:call)

      post :event, params: { key: "wrong" }, format: :json
      expect(response.status).to eq(403)
    end

    it "should allow a correct webhook key" do
      expect(NotifySlackCommentDeliveryService).to_not receive(:call)

      post :event, params: { key: "abc123" }, format: :json
      expect(response.status).to eq(200)
    end

    it "should accept a test event but do nothing" do
      expect(NotifySlackCommentDeliveryService).to_not receive(:call)

      post :event, params: { key: "abc123", test_event: {} }, format: :json
      expect(response.status).to eq(200)
    end

    it "should accept a delivery event for an alert email but do nothing" do
      expect(NotifySlackCommentDeliveryService).to_not receive(:call)

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
      expect(response.status).to eq(200)
    end

    it "should accept a succesful delivery event for a comment email and do nothing" do
      expect(NotifySlackCommentDeliveryService).to_not receive(:call)

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
      expect(response.status).to eq(200)
    end

    it "should accept a bounce delivery event for a comment email and do something" do
      comment = create(:comment, id: 12)
      expect(NotifySlackCommentDeliveryService).to receive(:call).with(
        comment: comment,
        to: "joy@smart-unlimited.com",
        status: "hard_bounce",
        extended_status: "hard bounce",
        email_id: 123
      )

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
      expect(response.status).to eq(200)
    end
  end
end
