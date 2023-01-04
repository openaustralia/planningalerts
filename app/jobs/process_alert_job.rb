# typed: strict
# frozen_string_literal: true

class ProcessAlertJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { params(id: Integer).void }
  def perform(id)
    alert = Alert.find_by(id:)
    # If the alert has been deleted, for example by a user removing their account
    # then just skip over and don't cause any kind of error
    return if alert.nil?

    ProcessAlertAndRecordStatsService.call(alert:)
  end
end
