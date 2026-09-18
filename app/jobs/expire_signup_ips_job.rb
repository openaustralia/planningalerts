# typed: strict
# frozen_string_literal: true

# Clears the IP addresses recorded when people sign up, once they're older than
# RETENTION_PERIOD. We record them so we can spot several signups coming from one place
# when we're looking at spam or abuse, and under the Australian Privacy Principles we
# shouldn't hold personal information for longer than we need it for that.
#
# Runs daily from config/cron.yml. Note that Sentry's sidekiq_cron patch creates one cron
# monitor per job class, so don't point a second cron entry at this class.
class ExpireSignupIpsJob
  extend T::Sig
  include Sidekiq::Job

  RETENTION_PERIOD = T.let(90.days, ActiveSupport::Duration)

  # Bounds the row lock and the transaction, so a first run over an accumulated backlog
  # can't sit on a lock while people are signing up.
  BATCH_SIZE = 5_000

  sig { void }
  def perform
    cutoff = RETENTION_PERIOD.ago

    expire(Alert.where.not(signup_ip: nil).where(created_at: ..cutoff), "alerts")
    expire(User.where.not(signup_ip: nil).where(created_at: ..cutoff), "users")
  end

  private

  # update_all deliberately skips callbacks and doesn't bump updated_at. Neither Alert nor
  # User has has_paper_trail, so nothing keeps a copy of the value we're clearing.
  sig { params(scope: ActiveRecord::Relation, label: String).void }
  def expire(scope, label)
    expired = 0
    # rubocop:disable Rails/SkipsModelValidations
    scope.in_batches(of: BATCH_SIZE) { |batch| expired += batch.update_all(signup_ip: nil) }
    # rubocop:enable Rails/SkipsModelValidations
    Rails.logger.info("ExpireSignupIpsJob: cleared signup_ip on #{expired} #{label}")
  end
end
