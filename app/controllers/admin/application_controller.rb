# typed: strict
# frozen_string_literal: true

# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    extend T::Sig

    include Administrate::Punditize
    before_action :authenticate_admin
    before_action :set_paper_trail_whodunnit

    # This controller does not inherit from the app's ApplicationController, so its
    # rescue_from for Pundit does not apply here. Without this a refused action is a 500.
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    sig { void }
    def authenticate_admin
      authenticate_user!
      render plain: "Not authorised", status: :forbidden unless T.must(current_user).can_login_to_admin?
    end

    sig { params(_error: Pundit::NotAuthorizedError).void }
    def user_not_authorized(_error)
      render plain: "Not authorised", status: :forbidden
    end

    sig { returns(T::Array[Symbol]) }
    def policy_namespace
      [:admin]
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
