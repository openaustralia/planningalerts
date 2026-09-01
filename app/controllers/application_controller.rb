# typed: strict
# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  extend T::Sig

  # For sorbet
  include Devise::Controllers::Helpers

  include Pundit::Authorization

  helper_method :altcha_required?, :altcha_enforced?

  helper :all # include all helpers, all the time
  protect_from_forgery with: :exception # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_action :configure_permitted_parameters, if: :devise_controller?
  # This stores the location on every request so that we can always redirect back after logging in
  # See https://github.com/heartcombo/devise/wiki/How-To:-%5BRedirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update%5D
  before_action :store_user_location!, if: :storable_location?
  before_action :set_sentry_user

  default_form_builder FormBuilders::Tailwind

  rescue_from ActiveRecord::StatementInvalid, with: :check_for_write_during_maintenance_mode
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # ALTCHA, the proof-of-work check on our public forms. See doc/altcha.md.
  #
  # Two flags drive this, both described in config/initializers/flipper.rb:
  #
  #   altcha         show the widget and check the answer
  #   altcha_enforce turn a failed check into a rejection
  #
  # With altcha on and altcha_enforce off we are in monitor mode: the widget is
  # shown, the answer is checked, the outcome is counted, and the form goes
  # through either way. That is how we find out what enforcing would cost before
  # anybody is turned away.
  #
  # These live here rather than in a concern because Sorbet's requires_ancestor
  # is still experimental and off in sorbet/config, so a module couldn't see
  # current_user, session or params.

  # The Flipper actor for the person in front of us.
  #
  # Signed out, this is a Visitor keyed on a value we keep in the session, which
  # gives a percentage gate something stable to hash. The session is written
  # rather than read from session.id, because a cookie session has no id until
  # something is stored in it, and because Devise rotates the session on sign
  # in.
  #
  # This writes to the session even when the flag is off, since Flipper needs an
  # actor before it can answer. That costs nothing: every page with one of these
  # forms already sets a session cookie for the CSRF token.
  sig { returns(T.any(User, Visitor)) }
  def altcha_actor
    user = current_user
    return user if user

    session[:altcha_id] ||= SecureRandom.uuid
    Visitor.new(T.cast(session[:altcha_id], String))
  end

  # Should this form show a check and have the answer looked at?
  sig { returns(T::Boolean) }
  def altcha_required?
    Flipper.enabled?(:altcha, altcha_actor)
  end

  # Would a failed check actually reject the submission?
  sig { returns(T::Boolean) }
  def altcha_enforced?
    altcha_required? && Flipper.enabled?(:altcha_enforce, altcha_actor)
  end

  # True when the request may go ahead. Always records the outcome. Only ever
  # returns false when altcha_enforce is on.
  sig { params(form: Symbol).returns(T::Boolean) }
  def altcha_ok?(form:)
    return true unless altcha_required?

    # Anything but a string is somebody poking at us, not a browser: params
    # can be an array or a hash if the query string says so.
    payload = params[:altcha]
    result = VerifyAltchaSolutionService.call(payload: payload.is_a?(String) ? payload : nil)
    report_altcha_result(form:, result:)
    result.verified || !Flipper.enabled?(:altcha_enforce, altcha_actor)
  end

  sig { params(form: Symbol, result: VerifyAltchaSolutionService::Result).void }
  def report_altcha_result(form:, result:)
    outcome = result.failure&.serialize || "verified"
    Sentry.metrics.count(
      "altcha.checks",
      value: 1,
      attributes: { form: form.to_s, outcome:, enforcing: altcha_enforced?.to_s }
    )

    # Only the surprising failures are worth an event. Missing is the ordinary
    # case in monitor mode, mostly meaning JavaScript did not run, and one
    # message per submission would swallow the Sentry quota to say what the
    # counter above already says.
    return unless notable_altcha_failure?(result.failure)

    Sentry.capture_message(
      "ALTCHA check failed: #{outcome}",
      level: :warning,
      tags: { altcha_form: form.to_s, altcha_outcome: outcome }
    )
  end

  sig { params(failure: T.nilable(VerifyAltchaSolutionService::Failure)).returns(T::Boolean) }
  def notable_altcha_failure?(failure)
    [
      VerifyAltchaSolutionService::Failure::InvalidSignature,
      VerifyAltchaSolutionService::Failure::Replayed
    ].include?(failure)
  end

  # Attach the signed-in person to Sentry events by id only, never email
  # (Australian Privacy Principles). Look the id up in the admin backend if
  # you need to contact someone about an error.
  sig { void }
  def set_sentry_user
    user = current_user
    Sentry.set_user(id: user.id) if user
  end

  sig { params(_error: Pundit::NotAuthorizedError).void }
  def user_not_authorized(_error)
    redirect_back fallback_location: root_path, alert: t("pundit.not_authorized")
  end

  sig { params(error: StandardError).void }
  def check_for_write_during_maintenance_mode(error)
    # Checking for postgres responses that we don't have permission which means
    # we're trying to do a write operation when we're only allowed to do read operations.
    raise error unless Flipper.enabled?(:maintenance_mode) && error.message.match?(/PG::InsufficientPrivilege/)

    Rails.logger.warn "Write attempted during maintenance mode: #{error}"

    redirect_back(
      fallback_location: root_path,
      alert: t("activerecord.errors.write_during_maintenance_mode")
    )
  end

  sig { void }
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :current_password) }
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request is not a Turbo Frame request ([turbo-rails](https://github.com/hotwired/turbo-rails/blob/main/app/controllers/turbo/frames/frame_request.rb))
  sig { returns(T::Boolean) }
  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      controller_name != "activations" &&
      !request.xhr?
    # &&
    # !turbo_frame_request?
  end

  sig { void }
  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
