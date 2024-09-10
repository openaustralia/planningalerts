# typed: strict
# frozen_string_literal: true

class AuthorityPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(Authority) }
  def authority
    T.cast(@authority, Authority)
  end

  sig { params(user: User, authority: T.any(Authority, T.class_of(Authority))).void }
  def initialize(user, authority)
    super
    @user = user
    @authority = authority
  end

  sig { returns(T::Boolean) }
  def create?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def index?
    true
  end

  # TODO: Allow everyone to see an active authority
  sig { returns(T::Boolean) }
  def show?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def update?
    user.has_role?(:admin)
  end

  sig { returns(T::Boolean) }
  def import?
    user.has_role?(:admin)
  end

  class Scope < ApplicationPolicy::Scope
    sig { returns(ActiveRecord::Relation) }
    def resolve
      user.has_role?(:admin) ? scope.all : scope.enabled
    end
  end
end
