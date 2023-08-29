# typed: strict
# frozen_string_literal: true

module Tailwind
  class ButtonComponent < ViewComponent::Base
    extend T::Sig

    sig { params(tag: Symbol, size: String, type: Symbol, href: T.nilable(String)).void }
    def initialize(tag:, size:, type:, href: nil)
      super
      raise "Unexpected tag: #{tag}" unless %i[a button].include?(tag)
      raise "href not set" if href.nil? && tag == :a

      case size
      when "lg"
        classes = %w[px-4 py-2 text-lg]
      when "2xl"
        classes = %w[px-11 sm:px-16 py-3 sm:py-4 text-2xl]
      else
        raise "Unexpected size #{size}"
      end

      case type
      when :primary
        classes << "bg-green"
      # This is not strictly an "inverse" but is good to be used on darker coloured backgrounds
      when :inverse
        classes << "bg-navy"
      else
        raise "Unexpected type #{type}"
      end
      classes += %w[font-semibold text-white]
      @classes = T.let(classes, T.nilable(T::Array[String]))
      @tag = tag
      @href = href
    end
  end
end
