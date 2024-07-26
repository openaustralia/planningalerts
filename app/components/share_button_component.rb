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
end
