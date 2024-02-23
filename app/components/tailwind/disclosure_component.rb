# typed: strict
# frozen_string_literal: true

module Tailwind
  class DisclosureComponent < ViewComponent::Base
    extend T::Sig

    renders_one :summary

    SIZES = T.let({ "base" => "text-base", "xl" => "text-xl", "2xl" => "text-2xl" }.freeze, T::Hash[String, String])

    sig { params(size: String).void }
    def initialize(size:)
      super
      size_class = SIZES[size]
      raise "Unexpected size: #{size}" if size_class.nil?

      @size_class = T.let(size_class, String)
    end
  end
end
