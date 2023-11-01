# typed: strict
# frozen_string_literal: true

module Tailwind
  class Heading < ViewComponent::Base
    extend T::Sig

    sig { params(tag: Symbol, extra_classes: String).void }
    def initialize(tag:, extra_classes: "")
      super

      raise "Invalid tag" unless tag == :h1

      @extra_classes = extra_classes
    end
  end
end
