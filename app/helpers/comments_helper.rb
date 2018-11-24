# frozen_string_literal: true

module CommentsHelper
  def comment_as_html(text)
    # duplicate string to avoid "can't modify frozen String"
    cleaned = Sanitize.clean(simple_format(auto_link(text.dup)), Sanitize::Config::BASIC)
    # We're trusting that the sanitize library does the right thing here. We
    # kind of have to. It's returning some allowed html. So, we have to mark
    # it as safe
    # rubocop:disable Rails/OutputSafety
    cleaned.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def comment_path(comment)
    application_path(comment.application, anchor: "comment#{comment.id}")
  end

  def comment_url(comment)
    application_url(comment.application, anchor: "comment#{comment.id}")
  end
end
