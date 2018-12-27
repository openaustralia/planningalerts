# frozen_string_literal: true

module AtdisHelper
  def attribute_value(value)
    if value.is_a?(Array)
      safe_join(value.map { |v| attribute_value(v) })
    elsif value.class.respond_to?(:attribute_names)
      render partial: "attribute_table", locals: { model: value }
    elsif value.is_a?(DateTime)
      content_tag(:div, time_tag(value) + " (" + time_ago_in_words(value) + " ago)", class: "value")
    elsif value.is_a?(URI)
      content_tag(:div, link_to(value.to_s, value.to_s), class: "value")
    elsif value.respond_to?(:x) && value.respond_to?(:y)
      content_tag(:div, h(value) + content_tag(:p, google_static_map2(value.y, value.x, zoom: 12, size: "300x150")), class: "value")
    elsif value.is_a?(RGeo::Cartesian::PolygonImpl)
      content_tag(:div, h(value), class: "value")
    elsif value.is_a?(NilClass)
      content_tag(:div, content_tag(:p, "absent or null", class: "quiet"), class: "value")
    elsif value.is_a?(String)
      content_tag(:div, h(value), class: "value")
    else
      content_tag(:div, h(value.inspect), class: "value")
    end
  end
end
