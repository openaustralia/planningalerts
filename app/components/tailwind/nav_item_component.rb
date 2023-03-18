# typed: strict

module Tailwind
  class NavItemComponent < ViewComponent::Base
    extend T::Sig

    sig { params(text: String, url: String, selected: T::Boolean).void }
    def initialize(text:, url:, selected: false)
      super
      @text = text
      @url = url
      @selected = selected
    end
  end
end
