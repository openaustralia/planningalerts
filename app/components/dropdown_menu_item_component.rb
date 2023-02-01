# typed: strict
# frozen_string_literal: true

class DropdownMenuItemComponent < ViewComponent::Base
  def initialize(disabled:)
    @disabled = disabled
  end
end
