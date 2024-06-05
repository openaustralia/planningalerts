# typed: strict
# frozen_string_literal: true

module Tailwind
  class SpeechBubbleComponent < ViewComponent::Base
    extend T::Sig

    sig { params(size: String, alignment: Symbol).void }
    def initialize(size:, alignment:)
      super

      # Doing it this way so that tailwind doesn't compile the classes out
      case size
      when "4xl"
        box_classes = "px-4 py-2 text-4xl rounded-2xl"
        arrow_classes = "border-l-[6px] border-t-[14px] border-r-[6px]"
        alignment_class = case alignment
                          when :left
                            "left-4"
                          when :right
                            "right-4"
                          else
                            raise "Only :left or :right for alignment"
                          end
      when "3xl"
        box_classes = "px-4 py-2 text-3xl rounded-2xl"
        arrow_classes = "border-l-[6px] border-t-[14px] border-r-[6px]"
        alignment_class = case alignment
                          when :left
                            "left-4"
                          when :right
                            "right-4"
                          else
                            raise "Only :left or :right for alignment"
                          end
      when "2xl"
        box_classes = "px-4 py-2 text-2xl rounded-2xl"
        arrow_classes = "border-l-[6px] border-t-[14px] border-r-[6px]"
        alignment_class = case alignment
                          when :left
                            "left-4"
                          when :right
                            "right-4"
                          else
                            raise "Only :left or :right for alignment"
                          end
      when "lg"
        box_classes = "px-2 text-lg rounded-lg"
        arrow_classes = "border-l-[3px] border-t-[6px] border-r-[3px]"
        alignment_class = case alignment
                          when :left
                            "left-2"
                          when :right
                            "right-2"
                          else
                            raise "Only :left or :right for alignment"
                          end
      else
        raise "Not supporting the size #{size} yet"
      end

      @box_classes = T.let(box_classes, String)
      @arrow_classes = T.let(arrow_classes, String)
      @alignment = T.let(alignment_class, String)
    end
  end
end
