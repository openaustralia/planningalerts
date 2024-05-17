# typed: strict
# frozen_string_literal: true

module Tailwind
  class ShareButton < ViewComponent::Base
    extend T::Sig

    sig { params(url: String, color: Symbol).void }
    def initialize(url:, color:)
      super
      @url = url
      case color
      when :green
        @text_class = T.let("text-green", String)
      when :lavender
        @text_class = "text-lavender"
      else
        raise "Unexpected color: #{color}"
      end
    end
  end
end
