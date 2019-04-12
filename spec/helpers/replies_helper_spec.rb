# frozen_string_literal: true

require "spec_helper"

describe RepliesHelper do
  describe "#reply_path" do
    let(:application) { create_geocoded_application(id: 1) }
    let(:reply) { create(:reply, id: 1, comment: create(:confirmed_comment, application: application)) }

    it "returns the path for the application with an anchor with the reply id" do
      expect(helper.reply_path(reply)).to eq "/applications/1#reply1"
    end
  end
end
