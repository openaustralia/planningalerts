# typed: strict
# frozen_string_literal: true

class CentreBlockWithImageComponent < ViewComponent::Base
  extend T::Sig

  renders_one :heading
  renders_one :image

  sig { params(extra_classes: String).void }
  def initialize(extra_classes: "")
    super

    @extra_classes = extra_classes
  end
end
