# typed: true
# frozen_string_literal: true

class CouncillorContributionMailer < ApplicationMailer
  def notify(councillor_contribution)
    @councillor_contribution = councillor_contribution
    mail(
      to: ENV["EMAIL_MODERATOR"],
      subject: "PlanningAlerts: New councillor contribution",
      from: ENV["EMAIL_MODERATOR"]
    )
  end
end
