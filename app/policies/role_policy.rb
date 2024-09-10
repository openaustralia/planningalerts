# typed: strict

class RolePolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(T::Boolean) }
  def index?
    user.admin?
  end

  sig { returns(T::Boolean) }
  def show?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    sig { returns(ActiveRecord::Relation) }
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end
