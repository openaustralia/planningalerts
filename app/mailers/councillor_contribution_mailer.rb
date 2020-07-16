# typed: strict
# frozen_string_literal: true

class CouncillorContributionMailer < ApplicationMailer
  extend T::Sig

  sig do
    params(
      councillor_contribution: CouncillorContribution
    ).returns(Mail::Message)
  end
  def notify(councillor_contribution)
    @councillor_contribution = T.let(
      councillor_contribution, T.nilable(CouncillorContribution)
    )
    mail(
      to: ENV["EMAIL_MODERATOR"],
      subject: "PlanningAlerts: New councillor contribution",
      from: ENV["EMAIL_MODERATOR"]
    )
  end
end
