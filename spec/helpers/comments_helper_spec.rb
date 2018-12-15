# frozen_string_literal: true

require "spec_helper"

describe CommentsHelper do
  describe "#comment_as_html" do
    it "wraps lines of text in HTML paragraphs" do
      expect(helper.comment_as_html("This is a paragraph\n\nThis is another paragraph"))
        .to eql "<p>This is a paragraph</p>\n\n<p>This is another paragraph</p>"
    end

    it "adds links to urls in text" do
      expect(helper.comment_as_html("I love http://planningalerts.org.au"))
        .to eql %(<p>I love <a href="http://planningalerts.org.au" rel="nofollow">http://planningalerts.org.au</a></p>)
    end

    it "removes scary scripts" do
      expect(helper.comment_as_html("watch out <script>alert('danger');</script>"))
        .to eql "<p>watch out alert('danger');</p>"
    end

    it { expect(helper.comment_as_html("watch out <script>alert('danger');</script>")).to be_html_safe }
  end

  describe "#comment_path" do
    let(:application) { VCR.use_cassette("planningalerts") { create(:application, id: 1) } }
    let(:comment) { create(:confirmed_comment, id: 1, application: application) }

    it "returns the path for the application with an anchor with the comment id" do
      expect(helper.comment_path(comment)).to eq "/applications/1#comment1"
    end
  end

  describe "#comment_url" do
    let(:application) { VCR.use_cassette("planningalerts") { create(:application, id: 1) } }
    let(:comment) { create(:confirmed_comment, id: 1, application: application) }

    it "returns the url for the application with an anchor with the comment id" do
      expect(helper.comment_url(comment)).to eq "http://test.host/applications/1#comment1"
    end
  end
end
