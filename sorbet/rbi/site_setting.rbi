# typed: true

class SiteSetting < ApplicationRecord
  # Because it's serialized
  sig { returns(T::Hash[Symbol, T.untyped]) }
  def settings; end
end
