# typed: strict
# frozen_string_literal: true

# Sweeps ALTCHA solutions we no longer need to remember. Once a challenge has
# expired the verification step rejects it on age alone, so keeping the row
# adds nothing.
#
# This is a job rather than a rake task invoked through InvokeRakeTaskJob
# because Sentry's sidekiq_cron patch creates one monitor per job class, and a
# shared runner class would collapse them all into one monitor.
class DeleteExpiredAltchaSolutionsJob
  extend T::Sig
  include Sidekiq::Job

  sig { void }
  def perform
    AltchaSolution.where(expires_at: ...Time.zone.now).delete_all
  end
end
