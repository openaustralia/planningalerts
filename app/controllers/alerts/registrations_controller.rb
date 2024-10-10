# typed: strict
# frozen_string_literal: true

module Alerts
  class RegistrationsController < Devise::RegistrationsController
    extend T::Sig

    sig { void }
    def new
      super do
        @alert = T.let(Alert.new(address: params[:user][:address], radius_meters: params[:user][:radius_meters]), T.nilable(Alert))
      end
    end
  end
end
