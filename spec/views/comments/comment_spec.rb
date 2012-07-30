require 'spec_helper'

describe "comments/_comment" do
  it "should remove links in the comment text" do
    application = mock_model(Application)
    comment = mock_model(Comment, :name => "Matthew", :updated_at => Time.now, :application => application,
      :text => 'This is a link to <a href="http://openaustralia.org">openaustralia.org</a>')
    render :partial => "comment", :object => comment
    rendered.should == <<-EOF
<div class='comment'>
<div class='text'><p>This is a link to <a href="http://openaustralia.org" rel="nofollow">openaustralia.org</a></p></div>
<span class='author'>by Matthew less than a minute ago</span>
</div>
    EOF
  end

  it "should format simple text in separate paragraphs with p tags" do
    application = mock_model(Application)
    comment = mock_model(Comment, :name => "Matthew", :updated_at => Time.now, :application => application,
      :text => "This is the first paragraph\nAnd the next line\n\nThis is a new paragraph")
    render :partial => "comment", :object => comment
    rendered.should == <<-EOF
<div class='comment'>
<div class='text'><p>This is the first paragraph
<br>And the next line</p>

<p>This is a new paragraph</p></div>
<span class='author'>by Matthew less than a minute ago</span>
</div>
    EOF
  end

  it "should get rid of nasty javascript and strip out images" do
    application = mock_model(Application)
    comment = mock_model(Comment, :name => "Matthew", :updated_at => Time.now, :application => application,
      :text => "<a href=\"javascript:document.location='http://www.google.com/'\">A nasty link</a><img src=\"http://foo.co\">")
    render :partial => "comment", :object => comment
    rendered.should == <<-EOF
<div class='comment'>
<div class='text'><p><a rel="nofollow">A nasty link</a></p></div>
<span class='author'>by Matthew less than a minute ago</span>
</div>
    EOF
  end
end

