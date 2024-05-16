# typed: strict
# frozen_string_literal: true

module Tailwind
  extend T::Sig
  class AlertComponent < ViewComponent::Base
    extend T::Sig

    sig { params(type: T.anything).void }
    def initialize(type:)
      super

      @type = type
      case type
      when :success
        @bg_class = T.let("bg-lavender", String)
        @alignment_class = T.let("items-center", String)
        @padding_class = T.let("px-4 py-3", String)
      when :congratulations
        @bg_class = T.let("bg-lavender", String)
        @alignment_class = T.let("items-start", String)
        @padding_class = T.let("px-8 py-8", String)
      when :warning
        @bg_class = "bg-error-red"
        @alignment_class = T.let("items-center", String)
        @padding_class = T.let("px-4 py-3", String)
      else
        raise "Invalid value for type: #{type}"
      end
    end
  end
end
