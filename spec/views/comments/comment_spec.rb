# frozen_string_literal: true

require "spec_helper"

describe "comments/_comment" do
  before do
    Timecop.freeze(Time.zone.local(2015, 1, 26, 10, 5, 0))
  end

  let(:application) { create(:geocoded_application) }

  after do
    Timecop.return
  end

  it "adds rel='no-follow' to links in the comment text" do
    comment = create(:published_comment,
                     text: 'This is a link to <a href="http://openaustralia.org">openaustralia.org</a>',
                     application:)
    expected_html = "<p>This is a link to <a href=\"http://openaustralia.org\" rel=\"nofollow\">openaustralia.org</a></p>"

    render comment, show_extra: false

    expect(rendered).to include(expected_html)
  end

  it "formats simple text in separate paragraphs with p tags" do
    comment = create(:published_comment,
                     text: "This is the first paragraph\nAnd the next line\n\nThis is a new paragraph",
                     application:)
    expected_html = "<p>This is the first paragraph
<br>And the next line</p>

<p>This is a new paragraph</p>"

    render comment, show_extra: false

    expect(rendered).to include(expected_html)
  end

  it "gets rid of nasty javascript and strip out images" do
    comment = create(:published_comment,
                     text: "<a href=\"javascript:document.location='http://www.google.com/'\">A nasty link</a><img src=\"http://foo.co\">",
                     application:)
    expected_html = "<p><a rel=\"nofollow\">A nasty link</a></p>"

    render comment, show_extra: false

    expect(rendered).to include(expected_html)
  end
end
