# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    # TODO: Perhaps we should allow the size override to work by saying we want an h1 heading but with the styling of an h2?
    sig { params(tag: Symbol, size: T.nilable(String), extra_classes: String).void }
    def initialize(tag:, size: nil, extra_classes: "")
      super

      raise "Invalid tag" unless tag == :h1

      @extra_classes = extra_classes

      case size
      when "3xl"
        @size_class = T.let("text-3xl", String)
      # 4xl is the default size for h1
      when "4xl", nil
        @size_class = T.let("text-4xl", String)
      else
        raise "Unexpected size #{size}"
      end
    end
  end
end
