# typed: strict
# frozen_string_literal: true

class DropdownComponent < ViewComponent::Base
  renders_one :button
  renders_one :menu, "DropdownMenuComponent"

  class DropdownMenuComponent < ViewComponent::Base
    renders_many :items, "DropdownMenuItemComponent"

    class DropdownMenuItemComponent < ViewComponent::Base
      extend T::Sig

      sig { params(disabled: T::Boolean).void }
      def initialize(disabled:)
        super
        @disabled = disabled
      end
    end
  end
end
