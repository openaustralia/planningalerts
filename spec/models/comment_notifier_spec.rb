require 'spec_helper'

describe CommentNotifier do
  it "should be sent to the user's email address" do
    comment = mock_model(Comment, :email => "foo@bar.com")
    notifier = CommentNotifier.create_confirm(comment)
    notifier.to.should == [comment.email]
  end
end