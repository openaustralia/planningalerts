# typed: strict
# frozen_string_literal: true

class ProcessAlertJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { params(id: Integer).void }
  def perform(id)
    ProcessAlertAndRecordStatsService.call(alert_id: id)
  end
end
