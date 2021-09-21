# typed: strict

require "administrate/custom_dashboard"

class BackgroundJobDashboard < Administrate::CustomDashboard
  resource "BackgroundJob"
end
