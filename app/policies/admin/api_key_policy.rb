# typed: strict
# frozen_string_literal: true

module Admin
  class ApiKeyPolicy < ApplicationPolicy
    extend T::Sig

    sig { returns(T::Boolean) }
    def index?
      user.has_role?(:admin) || user.has_role?(:api_editor)
    end

    sig { returns(T::Boolean) }
    def show?
      user.has_role?(:admin) || user.has_role?(:api_editor)
    end

    sig { returns(T::Boolean) }
    def update?
      user.has_role?(:admin) || user.has_role?(:api_editor)
    end

    sig { returns(T::Boolean) }
    def create?
      user.has_role?(:admin) || user.has_role?(:api_editor)
    end

    class Scope < ApplicationPolicy::Scope
      sig { returns(ActiveRecord::Relation) }
      def resolve
        user.has_role?(:admin) || user.has_role?(:api_editor) ? scope.all : scope.none
      end
    end
  end
end
