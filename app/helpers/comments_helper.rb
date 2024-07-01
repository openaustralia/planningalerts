# typed: strict
# frozen_string_literal: true

module CommentsHelper
  extend T::Sig

  # to access our_sanitize
  include ApplicationHelper

  # For sorbet
  include ActionView::Helpers::TextHelper
  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Rails.application.routes.url_helpers

  sig { params(text: String).returns(String) }
  def comment_as_html(text)
    # duplicate string to avoid "can't modify frozen String"
    our_sanitize(simple_format(auto_link(text.dup)))
  end

  # This is useful in a situation where we're wrapping a whole comment in
  # a link and we don't want a link inside of a link
  sig { params(text: String).returns(String) }
  def comment_as_html_no_link(text)
    remove_links(comment_as_html(text))
  end

  # This removes the a tags but keeps the content inside
  sig { params(html: String).returns(String) }
  def remove_links(html)
    doc = Nokogiri::HTML5.fragment(html)
    doc.search("a").each do |a|
      # Put all the children of the links before the link
      a.children.each { |child| a.add_previous_sibling(child) }
      a.remove
    end
    # If the input is html safe then we can make the output safe too
    if html.html_safe?
      # rubocop:disable Rails/OutputSafety
      doc.to_s.html_safe
      # rubocop:enable Rails/OutputSafety
    else
      doc.to_s
    end
  end

  sig { params(text: String).returns(T::Array[String]) }
  def comment_as_html_paragraphs_no_link(text)
    result = []
    doc = Nokogiri::HTML5.fragment(comment_as_html_no_link(text))
    doc.children.each do |child|
      result << child.inner_html if child.name == "p"
    end
    # If the input is html safe then we can make the output safe too
    if text.html_safe?
      result
    else
      result.map(&:html_safe)
    end
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
