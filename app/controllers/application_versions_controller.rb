# typed: strict
# frozen_string_literal: true

class ApplicationVersionsController < ApplicationController
  extend T::Sig

  before_action :check_authorized

  sig { void }
  def index
    @application = T.let(Application.find(params[:application_id]), T.nilable(Application))
  end

  private

  sig { void }
  def check_authorized
    return if Flipper.enabled?(:view_application_versions, current_user)

    render plain: "You're not allowed to look the application update history. Sorry", status: :unauthorized
  end
end
