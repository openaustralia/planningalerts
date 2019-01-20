# frozen_string_literal: true

class ProcessAlertJob < ApplicationJob
  queue_as :default

  def perform(id)
    ProcessAlertsBatchService.call(alert_ids: [id])
  end
end
