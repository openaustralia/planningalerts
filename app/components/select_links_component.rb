# typed: strict
# frozen_string_literal: true

class SelectLinksComponent < ViewComponent::Base
  extend T::Sig
  include ApplicationHelper

  sig { params(label: String, id: String, container: T::Array[T::Array[String]], value: String).void }
  def initialize(label:, id:, container:, value:)
    super
    @label = label
    @id = id
    @container = container
    @value = value
  end
end
