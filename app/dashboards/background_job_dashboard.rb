# typed: strict
# frozen_string_literal: true

require "administrate/custom_dashboard"

class BackgroundJobDashboard < Administrate::CustomDashboard
  resource "BackgroundJob"
end
