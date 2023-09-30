# typed: strict
# frozen_string_literal: true

module Tailwind
  class DisclosureComponent < ViewComponent::Base
    extend T::Sig

    renders_one :summary

    sig { params(size: String).void }
    def initialize(size:)
      super
      @size = size
    end
  end
end
