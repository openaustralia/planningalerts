# typed: strict
# frozen_string_literal: true

module Tailwind
  class PanelListItem < ViewComponent::Base
    extend T::Sig

    sig { returns(Tailwind::LinkBlock) }
    attr_reader :link_block

    delegate :linkify, to: :link_block

    sig { params(url: String).void }
    def initialize(url:)
      super
      @link_block = T.let(Tailwind::LinkBlock.new(url:), Tailwind::LinkBlock)
    end
  end
end
