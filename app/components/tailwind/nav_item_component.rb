# typed: strict
# frozen_string_literal: true

module Tailwind
  class NavItemComponent < ViewComponent::Base
    extend T::Sig

    sig { params(href: String, selected: T::Boolean).void }
    def initialize(href:, selected: false)
      super
      @href = href
      @selected = selected
    end
  end
end
