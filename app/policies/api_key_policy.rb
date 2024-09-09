# typed: strict
# frozen_string_literal: true

class ApiKeyPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def update?
    user.admin?
  end

  def create?
    true
  end

  def confirm?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.where(user:)
    end
  end
end
