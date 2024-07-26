# typed: strict
# frozen_string_literal: true

module Tailwind
  class ButtonWithSideTextComponent < ViewComponent::Base
    extend T::Sig
    renders_one :side_text

    # options are just passed through to ButtonComponent
    sig { params(options: T.untyped).void }
    def initialize(**options)
      super
      @button = T.let(Tailwind::ButtonComponent.new(**T.unsafe(options)), Tailwind::ButtonComponent)
    end
  end
end
