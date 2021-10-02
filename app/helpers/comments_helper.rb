# typed: false
# frozen_string_literal: true

module CommentsHelper
  extend T::Sig

  # to access our_sanitize
  include ApplicationHelper

  sig { params(text: String).returns(String) }
  def comment_as_html(text)
    # duplicate string to avoid "can't modify frozen String"
    our_sanitize(simple_format(auto_link(text.dup)))
  end

  sig { params(comment: Comment).returns(String) }
  def comment_path(comment)
    application_path(comment.application, anchor: "comment#{comment.id}")
  end

  sig { params(comment: Comment).returns(String) }
  def comment_url(comment)
    application_url(comment.application, anchor: "comment#{comment.id}")
  end
end
