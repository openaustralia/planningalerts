# typed: strict
# frozen_string_literal: true

module Admin
  class HomesPolicy < ApplicationPolicy
    extend T::Sig

    sig { returns(T::Boolean) }
    def index?
      true
    end
  end
end
