# typed: strict
# frozen_string_literal: true

module Tailwind
  class PanelListItemComponent < ViewComponent::Base
    extend T::Sig

    sig { returns(Tailwind::LinkBlockComponent) }
    attr_reader :link_block

    delegate :linkify, to: :link_block

    sig { params(url: String).void }
    def initialize(url:)
      super
      @link_block = T.let(Tailwind::LinkBlockComponent.new(url:), Tailwind::LinkBlockComponent)
    end
  end
end
