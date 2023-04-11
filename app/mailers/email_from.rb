# typed: strict
# frozen_string_literal: true

module EmailFrom
  extend T::Sig

  private

  sig { returns(String) }
  def email_from
    "PlanningAlerts <#{ENV.fetch('EMAIL_FROM_ADDRESS', nil)}>"
  end
end
