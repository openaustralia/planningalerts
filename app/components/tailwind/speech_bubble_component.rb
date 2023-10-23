# typed: strict
# frozen_string_literal: true

module Tailwind
  class SpeechBubbleComponent < ViewComponent::Base
    extend T::Sig

    sig { params(size: String, alignment: Symbol).void }
    def initialize(size:, alignment:)
      super
      @size = size
      @alignment = alignment
      raise unless %i[left right].include?(alignment)
    end
  end
end
