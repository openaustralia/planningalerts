require 'spec_helper'

describe RepliesHelper do

  describe "#reply_path" do
   let(:application) { VCR.use_cassette('planningalerts') { create(:application, id: 1) } }
   let(:comment) { create(:confirmed_comment, application: application) }
   let(:reply) { create(:reply, id: 1, comment: comment) }

   it "returns the path for the application with an anchor with the reply id" do
     expect(helper.reply_path(reply)).to eq "/applications/1#reply1"
   end
  end
end
