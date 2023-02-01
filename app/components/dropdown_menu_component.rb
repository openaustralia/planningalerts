# typed: strict
# frozen_string_literal: true

class DropdownMenuComponent < ViewComponent::Base
  renders_many :items, DropdownMenuItemComponent
end
