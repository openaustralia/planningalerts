# typed: strict
# frozen_string_literal: true

class TestEmailsPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(T::Boolean) }
  def index?
    user.admin?
  end

  sig { returns(T::Boolean) }
  def create?
    user.admin?
  end
end
