# typed: strict
# frozen_string_literal: true

class DropdownMenuItemComponent < ViewComponent::Base
  extend T::Sig

  sig { params(disabled: T::Boolean).void }
  def initialize(disabled:)
    super
    @disabled = disabled
  end
end
