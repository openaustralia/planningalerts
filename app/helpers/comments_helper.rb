# typed: false
# frozen_string_literal: true

module CommentsHelper
  # to access our_sanitize
  include ApplicationHelper

  def comment_as_html(text)
    # duplicate string to avoid "can't modify frozen String"
    our_sanitize(simple_format(auto_link(text.dup)))
  end

  def comment_path(comment)
    application_path(comment.application, anchor: "comment#{comment.id}")
  end

  def comment_url(comment)
    application_url(comment.application, anchor: "comment#{comment.id}")
  end
end
