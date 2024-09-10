# typed: strict
# frozen_string_literal: true

class TestEmailsPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(T::Boolean) }
  def index?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def create?
    user.has_role?(:admin)
  end
end
