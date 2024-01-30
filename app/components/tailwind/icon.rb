# typed: strict
# frozen_string_literal: true

module Tailwind
  class Icon < ViewComponent::Base
    extend T::Sig

    sig { params(name: Symbol).void }
    def initialize(name:)
      super

      # Using inlined svg icons so that we can set their colour based on the current text colour
      case name
      when :trash
        icon_path = "application/svg/trash"
      when :edit
        icon_path = "application/svg/pencil"
      when :external
        icon_path = "application/svg/external"
      when :share
        # TODO: Share icon is not visually consistent with external link icon
        icon_path = "application/svg/share"
      else
        raise "Unexpected name #{name}"
      end

      @icon_path = T.let(icon_path, String)
    end
  end
end
