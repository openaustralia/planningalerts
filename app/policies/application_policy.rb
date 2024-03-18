# typed: strict
# frozen_string_literal: true

class ApplicationPolicy
  extend T::Sig

  sig { returns(User) }
  attr_reader :user

  sig { returns(T.untyped) }
  attr_reader :record

  sig { params(user: User, record: T.untyped).void }
  def initialize(user, record)
    @user = user
    @record = record
  end

  sig { returns(T::Boolean) }
  def index?
    false
  end

  sig { returns(T::Boolean) }
  def show?
    false
  end

  sig { returns(T::Boolean) }
  def create?
    false
  end

  sig { returns(T::Boolean) }
  def new?
    create?
  end

  sig { returns(T::Boolean) }
  def update?
    false
  end

  sig { returns(T::Boolean) }
  def edit?
    update?
  end

  sig { returns(T::Boolean) }
  def destroy?
    false
  end

  class Scope
    extend T::Sig

    sig { params(user: User, scope: T.untyped).void }
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    sig { returns(T.untyped) }
    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    sig { returns(User) }
    attr_reader :user

    sig { returns(T.untyped) }
    attr_reader :scope
  end
end
