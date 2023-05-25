# typed: strict
# frozen_string_literal: true

module Tailwind
  class ButtonComponent < ViewComponent::Base
    extend T::Sig

    sig { params(href: String).void }
    def initialize(href:)
      super
      @href = href
    end
  end
end
