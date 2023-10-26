# typed: strict
# frozen_string_literal: true

module Tailwind
  class SpeechBubbleComponent < ViewComponent::Base
    extend T::Sig

    sig { params(size: String, alignment: Symbol).void }
    def initialize(size:, alignment:)
      super
      @size = size

      # Doing it this way so that tailwind doesn't compile the class out
      alignment_class = case alignment
                        when :left
                          "left-4"
                        when :right
                          "right-4"
                        else
                          raise "Only :left or :right for alignment"
                        end
      @alignment = T.let(alignment_class, String)
    end
  end
end
