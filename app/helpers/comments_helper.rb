# frozen_string_literal: true

module CommentsHelper
  def comment_as_html(text)
    # duplicate string to avoid "can't modify frozen String"
    Sanitize.clean(simple_format(auto_link(text.dup)), Sanitize::Config::BASIC).html_safe
  end

  def comment_path(comment)
    application_path(comment.application, anchor: "comment#{comment.id}")
  end

  def comment_url(comment)
    application_url(comment.application, anchor: "comment#{comment.id}")
  end
end
