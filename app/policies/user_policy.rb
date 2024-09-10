# typed: strict
# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  extend T::Sig

  # TODO: Extract this into a DefaultAdminPolicy
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
  def destroy?
    user.has_role?(:admin)
  end

  class Scope < ApplicationPolicy::Scope
    sig { returns(ActiveRecord::Relation) }
    def resolve
      user.has_role?(:admin) ? scope.all : scope.none
    end
  end
end
