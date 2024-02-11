# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), color: T.nilable(String), font: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, color: nil, font: nil, extra_classes: "")
      super

      font ||= "display"

      font_class = case font
                   when "display"
                     "font-display"
                   when "sans"
                     "font-sans"
                   else
                     raise "Unexpected font #{font}"
                   end

      default_size = case tag
                     when :h1
                       "4xl"
                     when :h2
                       "3xl"
                     when :h3
                       "2xl"
                     else
                       raise "Unexpected tag #{tag}"
                     end

      size ||= default_size

      size_class = case size
                   when "xl"
                     "text-xl"
                   when "2xl"
                     "text-2xl"
                   when "3xl"
                     "text-3xl"
                   when "4xl"
                     "text-4xl"
                   else
                     raise "Unexpected size #{size}"
                   end

      color_class = case color
                    when "fuchsia"
                      "text-fuchsia"
                    when "navy", nil
                      "text-navy"
                    else
                      raise "Unexpected color #{color}"
                    end

      @extra_classes = extra_classes
      @size_class = T.let(size_class, String)
      @color_class = T.let(color_class, String)
      @tag = tag
      @font_class = T.let(font_class, String)
    end
  end
end
