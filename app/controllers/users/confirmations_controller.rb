# typed: strict
# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    extend T::Sig

    # For sorbet
    include Devise::Controllers::Helpers
    include Split::Helper

    # create is Devise's, which is the whole point of subclassing: we only want
    # to put a check in front of it.
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :check_altcha, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter

    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # end

    # GET /resource/confirmation?confirmation_token=abcdef
    # def show
    #   super
    # end

    protected

    sig { void }
    def check_altcha
      return if altcha_ok?(form: :resend_confirmation)

      self.resource = resource_class.new(email: params.dig(:user, :email))
      resource.errors.add(:base, t("altcha.failed"))
      render :new, status: :unprocessable_entity
    end

    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    # The path used after confirmation.
    sig { params(_resource_name: Symbol, resource: User).returns(String) }
    def after_confirmation_path_for(_resource_name, resource)
      sign_in(resource)
      if resource.alerts.empty?
        after_sign_in_path_for(resource)
      else
        ab_finished(:logged_out_alert_flow_order)
        flash[:notice] = t("devise.confirmations.confirmed_with_alert", address: T.must(resource.alerts.first).address)
        alerts_path
      end
    end
  end
end
