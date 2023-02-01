# typed: strict
# frozen_string_literal: true

class DropdownComponent < ViewComponent::Base
  renders_one :button
  renders_one :menu, DropdownMenuComponent
end
