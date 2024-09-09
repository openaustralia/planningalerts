# typed: strict
# frozen_string_literal: true

class ApiUsagesPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
