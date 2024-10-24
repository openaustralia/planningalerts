# typed: strict
# frozen_string_literal: true

module Admin
  class ApplicationsPolicy < ApplicationPolicy
    extend T::Sig

    sig { returns(T::Boolean) }
    def index?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    sig { returns(T::Boolean) }
    def show?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    sig { returns(T::Boolean) }
    def destroy?
      user.has_role?(:admin)
    end

    class Scope < ApplicationPolicy::Scope
      sig { returns(ActiveRecord::Relation) }
      def resolve
        user.has_role?(:admin) || user.has_role?(:scraper_editor) ? scope.all : scope.none
      end
    end
  end
end
