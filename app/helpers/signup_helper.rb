# typed: true
# frozen_string_literal: true

module SignupHelper
  def draw_box_javascript(size, alert, zone_sizes)
    "preview(#{alert.location.lat}, #{alert.location.lng}, #{zone_sizes[size]});"
  end
end
