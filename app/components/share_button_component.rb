# typed: strict
# frozen_string_literal: true

class ShareButtonComponent < ViewComponent::Base
  extend T::Sig

  sig { params(url: String, title: String, color: Symbol).void }
  def initialize(url:, title:, color:)
    super
    @url = url
    @title = title
    case color
    when :green
      @text_class = T.let("text-green hover:text-dark-green focus:outline-none focus:bg-sun-yellow", String)
    when :lavender
      # TODO: Add hover state
      @text_class = "text-lavender focus:outline-none focus:bg-sun-yellow"
    else
      raise "Unexpected color: #{color}"
    end
  end

  sig { returns(String) }
  def url_with_tracking
    append_params(@url, utm_source: "share", utm_content: content.strip)
  end

  sig { params(url: String, params: T::Hash[String, String]).returns(String) }
  def append_params(url, params)
    u = URI.parse(url)
    e = Rack::Utils.parse_nested_query(u.query).merge(params).to_param
    u.query = e
    u.to_s
  end
end
