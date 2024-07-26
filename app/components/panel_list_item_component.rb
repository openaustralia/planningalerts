# typed: strict
# frozen_string_literal: true

class PanelListItemComponent < ViewComponent::Base
  extend T::Sig

  sig { returns(LinkBlockComponent) }
  attr_reader :link_block

  delegate :linkify, to: :link_block

  sig { params(url: String).void }
  def initialize(url:)
    super
    @link_block = T.let(LinkBlockComponent.new(url:), LinkBlockComponent)
  end
end
