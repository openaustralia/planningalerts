# typed: strict
# frozen_string_literal: true

require "administrate/custom_dashboard"

class HomeDashboard < Administrate::CustomDashboard
  resource "Homes"
end
