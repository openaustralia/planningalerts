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

  describe "#comment_as_html_no_link" do
    it "wraps lines of text in HTML paragraphs" do
      expect(helper.comment_as_html_no_link("This is a paragraph\n\nThis is another paragraph"))
        .to eql "<p>This is a paragraph</p>\n\n<p>This is another paragraph</p>"
    end

    it "does not add links to urls in text" do
      expect(helper.comment_as_html_no_link("I love http://planningalerts.org.au"))
        .to eql %(<p>I love http://planningalerts.org.au</p>)
    end

    it "removes existing links" do
      expect(helper.comment_as_html_no_link('<a href="foo">A link</a>')).to(eql "<p>A link</p>")
    end

    it "removes scary scripts" do
      expect(helper.comment_as_html_no_link("watch out <script>alert('danger');</script>"))
        .to eql "<p>watch out alert('danger');</p>"
    end

    it { expect(helper.comment_as_html_no_link("watch out <script>alert('danger');</script>")).to be_html_safe }
  end

  describe "#comments_as_html_paragraphs_no_link" do
    it "wraps lines of text in HTML paragraphs" do
      expect(helper.comment_as_html_paragraphs_no_link("This is a paragraph\n\nThis is another paragraph"))
        .to eql ["This is a paragraph", "This is another paragraph"]
    end

    it "returns a single paragraph" do
      expect(helper.comment_as_html_paragraphs_no_link("This is a paragraph"))
        .to eql ["This is a paragraph"]
    end

    it "is html safe" do
      r = helper.comment_as_html_paragraphs_no_link("This is a paragraph\n\nThis is another paragraph")
      expect(r[0]).to be_html_safe
      expect(r[1]).to be_html_safe
    end

    it "handles line breaks sensibly" do
      expect(helper.comment_as_html_paragraphs_no_link("p1\nlinebreak\n\np2"))
        .to eql ["p1\n<br>linebreak", "p2"]
    end
  end

  describe "#remove_links" do
    it "does nothing if there are no links" do
      expect(helper.remove_links("<p>Hello!</p>")).to eq "<p>Hello!</p>"
    end

    it "keeps the contents of the link" do
      expect(helper.remove_links('<p><a href="foo">Hello!</a></p>')).to eq "<p>Hello!</p>"
    end

    it "maintains the order of the children of the link" do
      expect(helper.remove_links('<p><a href="foo"><span>Hello!</span><span>Goodbye!</span></a></p>')).to eq "<p><span>Hello!</span><span>Goodbye!</span></p>"
    end
  end

  describe "#comment_path" do
    let(:application) { create(:geocoded_application, id: 1) }
    let(:comment) { create(:published_comment, id: 1, application:) }

    it "returns the path for the application with an anchor with the comment id" do
      expect(helper.comment_path(comment)).to eq "/applications/1#comment1"
    end
  end

  describe "#comment_url" do
    let(:application) { create(:geocoded_application, id: 1) }
    let(:comment) { create(:published_comment, id: 1, application:) }

    it "returns the url for the application with an anchor with the comment id" do
      expect(helper.comment_url(comment)).to eq "http://test.host/applications/1#comment1"
    end
  end
end
