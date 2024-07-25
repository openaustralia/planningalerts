# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  # This is still being used to do one click unsubscribes from email alerts
  sig { void }
  def unsubscribe
    @alert = T.let(Alert.find_by(confirm_id: params[:confirm_id]), T.nilable(Alert))
    @alert&.unsubscribe!
  end
end
