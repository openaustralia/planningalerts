# typed: strict
# frozen_string_literal: true

# A transitional Action Mailer delivery method for the move from Cuttlefish to
# Postal (#2234). It picks which SMTP server an email goes to at delivery time,
# so the cutover is a Flipper flag rather than a deploy, and so is the rollback.
#
# With the postal_smtp flag off (or not yet registered) everything goes to
# Cuttlefish, exactly as before. With it on, mail goes to one of the two Postal
# mail servers. PlanningAlerts has two so that alert bounces can never land a
# council address on the suppression list: see infrastructure ADR 0003.
# Everything defaults to the planningalerts server; CommentMailer names
# planningalerts_comments through delivery_method_options.
#
# The flag has no actor at send time, so only the boolean and percentage_of_time
# gates apply. percentage_of_time is safe here, unlike on a form, because each
# email is an independent event, which makes a staged rollout possible.
#
# If Flipper's redis is unreachable, Flipper.enabled? raises and the delivery job
# retries, the same shape of failure as the SMTP server being down. That is
# deliberate: quietly falling back to Cuttlefish would change the mail path
# during an outage, which is when a surprise is least welcome.
#
# Registered in config/environments/production.rb. Removed by #2236, which
# hardwires :smtp to Postal once Cuttlefish is retired.
class PostalOrCuttlefishSmtp
  extend T::Sig

  FLAG = :postal_smtp

  # The settings action mailer merged for this delivery: the hashes given to
  # add_delivery_method plus anything a mailer passed in delivery_method_options
  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :settings

  sig { params(settings: T::Hash[Symbol, T.untyped]).void }
  def initialize(settings)
    @settings = settings
  end

  sig { params(mail: Mail::Message).returns(T.untyped) }
  def deliver!(mail)
    Mail::SMTP.new(smtp_settings).deliver!(mail)
  end

  private

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def smtp_settings
    return settings.fetch(:cuttlefish) unless Flipper.enabled?(FLAG)

    server = settings.fetch(:mail_server, :planningalerts)
    settings.fetch(:postal).fetch(server) do
      raise ArgumentError, "Unknown postal mail server #{server.inspect}"
    end
  end
end
