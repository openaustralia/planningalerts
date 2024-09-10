# typed: strict

module Admin
  class HomesPolicy < ApplicationPolicy
    extend T::Sig

    sig { returns(T::Boolean) }
    def index?
      true
    end
  end
end
