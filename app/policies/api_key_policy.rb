# typed: strict
# frozen_string_literal: true

class ApiKeyPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(T::Boolean) }
  def index?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def show?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def update?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def create?
    true
  end

  sig { returns(T::Boolean) }
  def confirm?
    true
  end

  class Scope < ApplicationPolicy::Scope
    sig { returns(ActiveRecord::Relation) }
    def resolve
      user.has_role?(:admin) ? scope.all : scope.where(user:)
    end
  end
end
