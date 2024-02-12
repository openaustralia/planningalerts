# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    DEFAULT_SIZES = T.let({ h1: "4xl", h2: "3xl", h3: "2xl", h4: "2xl" }.freeze, T::Hash[Symbol, String])
    DEFAULT_FONTS = T.let({ h1: "display", h2: "display", h3: "display", h4: "sans" }.freeze, T::Hash[Symbol, String])
    # Doing this very long winded way to ensure that tailwind doesn't remove styles being used here
    VALID_SIZE_CLASSES = T.let(%w[text-xl text-2xl text-3xl text-4xl].freeze, T::Array[String])
    VALID_WEIGHT_CLASSES = T.let(%w[font-semibold font-bold].freeze, T::Array[String])
    VALID_COLOR_CLASSES = T.let(%w[text-fuchsia text-navy].freeze, T::Array[String])
    VALID_FONT_CLASSES = T.let(%w[font-display font-sans].freeze, T::Array[String])

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), color: T.nilable(String), font: T.nilable(String), weight: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, color: nil, font: nil, weight: nil, extra_classes: "")
      super

      default_size = DEFAULT_SIZES[tag]
      raise "Unexpected tag #{tag}" if default_size.nil?

      default_font = DEFAULT_FONTS[tag]
      raise "Unexpected tag #{tag}" if default_font.nil?

      # Set the default styling
      size ||= default_size
      weight ||= "bold"
      color ||= "navy"
      font ||= default_font

      raise "Unexpected size #{size}" unless VALID_SIZE_CLASSES.include?("text-#{size}")
      raise "Unexpected weight #{weight}" unless VALID_WEIGHT_CLASSES.include?("font-#{weight}")
      raise "Unexpected color #{color}" unless VALID_COLOR_CLASSES.include?("text-#{color}")
      raise "Unexpected font #{font}" unless VALID_FONT_CLASSES.include?("font-#{font}")

      c = ["text-#{size}", "font-#{weight}", "text-#{color}", "font-#{font}"]

      # TODO: Not sure whether we should be setting max width on all headings
      c << "max-w-4xl" if tag == :h1

      # These extra classes can't override the default styling because they're at the end
      c << extra_classes

      @tag = tag
      @class = T.let(c, T::Array[T.nilable(String)])
    end
  end
end
