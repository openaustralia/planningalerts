require 'spec_helper'

describe "comments/_comment" do
  before do
    Timecop.freeze(Time.local(2015, 1, 26, 10, 5, 0))
  end

  after do
    Timecop.return
  end

  it "should add rel='no-follow' to links in the comment text" do
    application = mock_model(Application)
    comment = mock_model(Comment, name: "Matthew", updated_at: Time.now, application: application,
      text: 'This is a link to <a href="http://openaustralia.org">openaustralia.org</a>')
    expected_html = "<blockquote class='comment-text'><p>This is a link to <a href=\"http://openaustralia.org\" rel=\"nofollow\">openaustralia.org</a></p></blockquote>"

    render partial: "comment", object: comment

    expect(rendered).to include(expected_html)
  end

  it "should format simple text in separate paragraphs with p tags" do
    application = mock_model(Application)
    comment = mock_model(Comment, name: "Matthew", updated_at: Time.now, application: application,
      text: "This is the first paragraph\nAnd the next line\n\nThis is a new paragraph")
    expected_html = "<blockquote class='comment-text'><p>This is the first paragraph
<br>And the next line</p>

<p>This is a new paragraph</p></blockquote>"

    render partial: "comment", object: comment

    expect(rendered).to include(expected_html)
  end

  it "should get rid of nasty javascript and strip out images" do
    application = mock_model(Application)
    comment = mock_model(Comment, name: "Matthew", updated_at: Time.now, application: application,
      text: "<a href=\"javascript:document.location='http://www.google.com/'\">A nasty link</a><img src=\"http://foo.co\">")
    expected_html = "<blockquote class='comment-text'><p><a rel=\"nofollow\">A nasty link</a></p></blockquote>"

    render partial: "comment", object: comment

    expect(rendered).to include(expected_html)
  end
end
