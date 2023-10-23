# typed: strict
# frozen_string_literal: true

module Tailwind
  class SpeechBubbleComponent < ViewComponent::Base
    extend T::Sig

    sig { params(size: String).void }
    def initialize(size:)
      super
      @size = size
    end
  end
end
