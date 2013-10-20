module CommentsHelper
  def comment_as_html(text)
    Sanitize.clean(simple_format(text), Sanitize::Config::BASIC).html_safe
  end
end
