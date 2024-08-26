# typed: strict
# frozen_string_literal: true

class BulletListComponent < ViewComponent::Base
  extend T::Sig

  renders_many :items

  sig { params(space: T.nilable(Integer)).void }
  def initialize(space: nil)
    super

    space_css = if space == 6
                  "space-y-6"
                elsif space.nil?
                  ""
                else
                  raise "Unexpected space value: #{space}"
                end
    @space_css = T.let(space_css, String)
  end
end
