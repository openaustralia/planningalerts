# typed: strict

module Tailwind
  class NavItemComponent < ViewComponent::Base
    extend T::Sig

    sig { params(url: String, selected: T::Boolean).void }
    def initialize(url:, selected: false)
      super
      @url = url
      @selected = selected
    end
  end
end
