module CommentsHelper
  def comment_as_html(text)
    Sanitize.clean(simple_format(text), Sanitize::Config::BASIC).html_safe
  end

  def comment_path(comment)
    application_path(comment.application, anchor: "comment#{comment.id}")
  end
end
