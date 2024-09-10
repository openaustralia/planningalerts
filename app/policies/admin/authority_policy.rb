# typed: strict
# frozen_string_literal: true

module Admin
  class AuthorityPolicy < ApplicationPolicy
    extend T::Sig

    sig { returns(T::Boolean) }
    def create?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    sig { returns(T::Boolean) }
    def index?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    sig { returns(T::Boolean) }
    def show?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    sig { returns(T::Boolean) }
    def update?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    sig { returns(T::Boolean) }
    def import?
      user.has_role?(:admin) || user.has_role?(:scraper_editor)
    end

    class Scope < ApplicationPolicy::Scope
      sig { returns(ActiveRecord::Relation) }
      def resolve
        user.has_role?(:admin) || user.has_role?(:scraper_editor) ? scope.all : scope.none
      end
    end
  end
end
