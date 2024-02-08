# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), color: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, color: nil, extra_classes: "")
      super

      default_size = case tag
                     when :h1
                       "4xl"
                     when :h2
                       "3xl"
                     else
                       raise "Unexpected tag #{tag}"
                     end

      size ||= default_size

      size_class = case size
                   when "xl"
                     "text-xl"
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
    end
  end
end
