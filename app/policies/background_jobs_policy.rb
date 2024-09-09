# typed: strict
# frozen_string_literal: true

class BackgroundJobsPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
