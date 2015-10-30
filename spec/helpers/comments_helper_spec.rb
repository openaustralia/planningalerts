require 'spec_helper'

describe CommentsHelper do
  describe "#comment_path" do
    let(:comment) { VCR.use_cassette('planningalerts') { create(:confirmed_comment) } }

    it "returns the path for the application with an anchor for the comment" do
      expect(helper.comment_path(comment)).to eq application_path(comment.application, anchor: "comment#{comment.id}")
    end
  end
end

