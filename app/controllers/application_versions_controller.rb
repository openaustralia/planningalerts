# typed: strict
# frozen_string_literal: true

class ApplicationVersionsController < ApplicationController
  extend T::Sig

  before_action :check_authorized

  sig { void }
  def index
    application = Application.find(T.cast(params[:application_id], String))
    @application = T.let(application, T.nilable(Application))
    return unless application.hidden? && !current_user&.has_role?(:admin)

    render "applications/hidden", status: :forbidden
  end

  private

  sig { void }
  def check_authorized
    return if Flipper.enabled?(:view_application_versions, current_user)

    render plain: "You're not allowed to look the application update history. Sorry", status: :unauthorized
  end
end
