# typed: strict
# frozen_string_literal: true

class BackgroundJobsPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(T::Boolean) }
  def index?
    user.has_role?(:admin)
  end
end
