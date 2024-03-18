# typed: strict
# frozen_string_literal: true

require "administrate/custom_dashboard"

class ApiUsageDashboard < Administrate::CustomDashboard
  resource "ApiUsage"
end
