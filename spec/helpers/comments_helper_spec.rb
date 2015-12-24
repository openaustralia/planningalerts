require 'spec_helper'

describe CommentsHelper do
  describe "#comment_path" do
    let(:application) { VCR.use_cassette('planningalerts') { create(:application, id: 1) } }
    let(:comment) { create(:confirmed_comment, id: 1, application: application) }

    it "returns the path for the application with an anchor with the comment id" do
      expect(helper.comment_path(comment)).to eq "/applications/1#comment1"
    end
  end

  describe "#comment_url" do
    let(:application) { VCR.use_cassette('planningalerts') { create(:application, id: 1) } }
    let(:comment) { create(:confirmed_comment, id: 1, application: application) }

    it "returns the url for the application with an anchor with the comment id" do
      expect(helper.comment_url(comment)).to eq "http://test.host/applications/1#comment1"
    end
  end
end

