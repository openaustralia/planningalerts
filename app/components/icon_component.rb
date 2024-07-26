# typed: strict
# frozen_string_literal: true

class IconComponent < ViewComponent::Base
  extend T::Sig

  sig { params(name: Symbol).void }
  def initialize(name:)
    super
    @name = name
  end
end
