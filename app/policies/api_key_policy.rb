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

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end
