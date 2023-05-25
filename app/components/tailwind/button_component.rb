# typed: strict
# frozen_string_literal: true

module Tailwind
  class ButtonComponent < ViewComponent::Base
    extend T::Sig

    sig { params(tag: Symbol, href: T.nilable(String)).void }
    def initialize(tag:, href: nil)
      super
      raise "Unexpected tag: #{tag}" unless %i[a button].include?(tag)
      raise "href not set" if href.nil? && tag == :a

      @tag = tag
      @href = href
    end
  end
end
