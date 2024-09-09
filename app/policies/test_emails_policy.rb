# typed: strict
# frozen_string_literal: true

class TestEmailsPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end
end
