# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), color: T.nilable(String), font: T.nilable(String), weight: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, color: nil, font: nil, weight: nil, extra_classes: "")
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

      weight ||= "bold"
      weight_class = case weight
                     when "semibold"
                       "font-semibold"
                     when "bold"
                       "font-bold"
                     else
                       raise "Unexpected weight #{weight}"
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


      # TODO: Not sure whether we should be setting max width on all headings
      c = if tag == :h1
            "#{size_class} #{weight_class} #{color_class} #{font_class} max-w-4xl #{extra_classes}"
          else
            "#{size_class} #{weight_class} #{color_class} #{font_class} #{extra_classes}"
          end

      @tag = tag
      @class = T.let(c, String)
    end
  end
end
