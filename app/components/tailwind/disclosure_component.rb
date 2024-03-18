# typed: strict
# frozen_string_literal: true

module Tailwind
  class DisclosureComponent < ViewComponent::Base
    extend T::Sig

    renders_one :summary

    SIZES = T.let({ "base" => "text-base", "xl" => "text-xl", "2xl" => "text-2xl" }.freeze, T::Hash[String, String])

    # If always_open is false it's not really a disclosure component - it just looks similar to how the component
    # looks when it's been opened except there's no disclosure triangle and clicking the summary doesn't do anything
    sig { params(size: String, always_open: T::Boolean).void }
    def initialize(size:, always_open: false)
      super
      size_class = SIZES[size]
      raise "Unexpected size: #{size}" if size_class.nil?

      @size_class = T.let(size_class, String)
      @always_open = always_open
    end
  end
end
