# typed: strict
# frozen_string_literal: true

module Standard
  class DropdownComponent < ViewComponent::Base
    renders_one :button
    renders_one :menu, "MenuComponent"

    class MenuComponent < ViewComponent::Base
      renders_many :items, "ItemComponent"

      class ItemComponent < ViewComponent::Base
        extend T::Sig

        sig { params(disabled: T::Boolean).void }
        def initialize(disabled:)
          super
          @disabled = disabled
        end
      end
    end
  end
end
