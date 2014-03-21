module AtdisHelper
  def yes_no(v)
    v ? "yes" : "no"
  end

  def attribute_value(value)
    if value.kind_of?(Array)
      value.map{|v| attribute_value(v)}.join.html_safe
    elsif value.class.respond_to?(:attribute_names)
      render :partial => "attribute_table", :locals => {:model => value}
    elsif value.kind_of?(DateTime)
      content_tag(:div, time_tag(value) + " (" + time_ago_in_words(value) + " ago)", class: "value")
    elsif value.kind_of?(URI)
      content_tag(:div, link_to(value.to_s, value.to_s), class: "value")
    elsif value.kind_of?(RGeo::Cartesian::PointImpl)
      content_tag(:div, h(value) + content_tag(:p, google_static_map2(:lat => value.y, :lng => value.x, :zoom => 12, :size => "300x150")), class: "value")
    elsif value.kind_of?(RGeo::Cartesian::PolygonImpl)
      content_tag(:div, h(value), class: "value")
    elsif value.kind_of?(NilClass)
      content_tag(:div, content_tag(:p, "absent or null", :class => "quiet"), class: "value")
    elsif value.kind_of?(String)
      content_tag(:div, h(value), class: "value")
    else
      content_tag(:div, h(value.inspect), class: "value")
    end
  end
end
