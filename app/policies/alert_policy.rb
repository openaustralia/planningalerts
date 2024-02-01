# typed: strict
# frozen_string_literal: true

class AlertPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(User) }
  attr_reader :user

  sig { returns(Alert) }
  attr_reader :alert

  sig { params(user: User, alert: Alert).void }
  def initialize(user, alert)
    super
    @user = user
    @alert = alert
  end

  sig { returns(T::Boolean) }
  def create?
    true
  end

  sig { returns(T::Boolean) }
  def update?
    alert.user_id == user.id && !alert.unsubscribed?
  end

  sig { returns(T::Boolean) }
  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    sig { returns(ActiveRecord::Relation) }
    def resolve
      # Use can only see their own active alerts
      scope.where(user:).active
    end
  end
end
