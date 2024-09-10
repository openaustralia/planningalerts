# frozen_string_literal: true

# Only admins can access flipper (the feature flag panel)
class CanAccessFlipperUI
  def self.matches?(request)
    current_user = request.env["warden"].user
    current_user&.has_role?(:admin)
  end
end
