# typed: strict
# frozen_string_literal: true

module Tailwind
  class SpeechBubbleComponent < ViewComponent::Base
    extend T::Sig

    sig { params(size: String, alignment: Symbol).void }
    def initialize(size:, alignment:)
      super

      box_classes = case size
                    when "4xl"
                      "px-4 py-2 text-4xl rounded-2xl"
                    when "2xl"
                      "px-4 py-2 text-2xl rounded-2xl"
                    when "lg"
                      "px-2 text-lg rounded-lg"
                    else
                      raise "Not supporting the size #{size} yet"
                    end
      @box_classes = T.let(box_classes, String)

      arrow_classes = case size
                      when "4xl", "2xl"
                        "border-l-[6px] border-t-[14px] border-r-[6px]"
                      when "lg"
                        "border-l-[3px] border-t-[6px] border-r-[3px]"
                      else
                        raise "Not supporting the size #{size} yet"
                      end
      @arrow_classes = T.let(arrow_classes, String)

      # Doing it this way so that tailwind doesn't compile the class out
      alignment_class = case alignment
                        when :left
                          case size

                          when "4xl", "2xl"
                            "left-4"
                          when "lg"
                            "left-2"
                          else
                            raise "Not supporting the size #{size} yet"
                          end
                        when :right
                          case size
                          when "4xl", "2xl"
                            "right-4"
                          when "lg"
                            "right-2"
                          else
                            raise "Not supporting the size #{size} yet"
                          end
                        else
                          raise "Only :left or :right for alignment"
                        end
      @alignment = T.let(alignment_class, String)
    end
  end
end
