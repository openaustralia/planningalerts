# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), color: T.nilable(String), font: T.nilable(String), weight: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, color: nil, font: nil, weight: nil, extra_classes: "")
      super

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

      # Set the default styling
      size ||= default_size
      weight ||= "bold"
      color ||= "navy"
      font ||= "display"

      c = []

      c << case size
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

      c << case weight
           when "semibold"
             "font-semibold"
           when "bold"
             "font-bold"
           else
             raise "Unexpected weight #{weight}"
           end

      c << case color
           when "fuchsia"
             "text-fuchsia"
           when "navy"
             "text-navy"
           else
             raise "Unexpected color #{color}"
           end

      c << case font
           when "display"
             "font-display"
           when "sans"
             "font-sans"
           else
             raise "Unexpected font #{font}"
           end

      # TODO: Not sure whether we should be setting max width on all headings
      c << "max-w-4xl" if tag == :h1

      # These extra classes can't override the default styling because they're at the end
      c << extra_classes

      @tag = tag
      @class = T.let(c, T::Array[String])
    end
  end
end
