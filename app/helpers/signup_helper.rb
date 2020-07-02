# typed: strict
# frozen_string_literal: true

module SignupHelper
  extend T::Sig

  sig { params(size: String, alert: Alert, zone_sizes: T::Hash[String, Integer]).returns(String) }
  def draw_box_javascript(size, alert, zone_sizes)
    "preview(#{T.must(alert.location).lat}, #{T.must(alert.location).lng}, #{zone_sizes[size]});"
  end
end
