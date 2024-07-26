# typed: strict
# frozen_string_literal: true

class AlertComponent < ViewComponent::Base
  extend T::Sig

  sig { params(type: T.anything).void }
  def initialize(type:)
    super

    case type
    when :success
      @bg_class = T.let("bg-lavender", String)
      @alignment_class = T.let("items-center", String)
      @padding_class = T.let("px-4 py-3", String)
      @icon_name = T.let(:tick, Symbol)
      @icon_class = T.let("text-light-lavender w-9 h-9", String)
    when :congratulations
      @bg_class = "bg-lavender"
      @alignment_class = "items-start"
      @padding_class = "px-8 py-8"
      @icon_name = :clapping
      @icon_class = "text-light-lavender"
    when :warning
      @bg_class = "bg-error-red"
      @alignment_class = "items-center"
      @padding_class = "px-4 py-3"
      @icon_name = :warning
      @icon_class = "text-white"
    else
      raise "Invalid value for type: #{type}"
    end
  end
end
