# typed: strict
# frozen_string_literal: true

class SimplePagerComponent < ViewComponent::Base
  extend T::Sig
  include ApplicationHelper

  sig { params(collection: T.untyped).void }
  def initialize(collection:)
    super
    @collection = collection
  end

  class Prev < ViewComponent::Base
    extend T::Sig
    include ApplicationHelper

    sig { params(collection: T.untyped).void }
    def initialize(collection:)
      super
      @collection = collection
    end
  end

  class Next < ViewComponent::Base
    extend T::Sig
    include ApplicationHelper

    sig { params(collection: T.untyped).void }
    def initialize(collection:)
      super
      @collection = collection
    end
  end
end
