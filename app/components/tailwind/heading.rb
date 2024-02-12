# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    DEFAULT_SIZES = T.let({ h1: "4xl", h2: "3xl", h3: "2xl" }.freeze, T::Hash[Symbol, String])
    # Doing this very long winded way to ensure that tailwind doesn't remove styles being used here
    SIZES = T.let({ "xl" => "text-xl", "2xl" => "text-2xl", "3xl" => "text-3xl", "4xl" => "text-4xl" }.freeze, T::Hash[String, String])
    WEIGHTS = T.let({ "semibold" => "font-semibold", "bold" => "font-semibold" }.freeze, T::Hash[String, String])
    COLORS = T.let({ "fuchsia" => "text-fuchsia", "navy" => "text-navy" }.freeze, T::Hash[String, String])
    FONTS = T.let({ "display" => "font-display", "sans" => "font-sans" }.freeze, T::Hash[String, String])

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), color: T.nilable(String), font: T.nilable(String), weight: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, color: nil, font: nil, weight: nil, extra_classes: "")
      super

      default_size = DEFAULT_SIZES[tag]
      raise "Unexpected tag #{tag}" if default_size.nil?

      # Set the default styling
      size ||= default_size
      weight ||= "bold"
      color ||= "navy"
      font ||= "display"

      raise "Unexpected size #{size}" unless SIZES.key?(size)
      raise "Unexpected weight #{weight}" unless WEIGHTS.key?(weight)
      raise "Unexpected color #{color}" unless COLORS.key?(color)
      raise "Unexpected font #{font}" unless FONTS.key?(font)

      c = [SIZES[size], WEIGHTS[weight], COLORS[color], FONTS[font]]

      # TODO: Not sure whether we should be setting max width on all headings
      c << "max-w-4xl" if tag == :h1

      # These extra classes can't override the default styling because they're at the end
      c << extra_classes

      @tag = tag
      @class = T.let(c, T::Array[T.nilable(String)])
    end
  end
end
