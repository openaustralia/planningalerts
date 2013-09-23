module AtdisHelper
  def yes_no(v)
    v ? "yes" : "no"
  end

  def attribute_value(value)
    if value.kind_of?(Array)
      value.map{|v| attribute_value(v)}.join.html_safe
    elsif value.class.respond_to?(:attribute_names)
      attribute_table(value)
    elsif value.kind_of?(DateTime)
      time_tag(value) + " (" + time_ago_in_words(value) + " ago)"
    elsif value.kind_of?(URI)
      link_to(value.to_s, value.to_s)
    elsif value.kind_of?(RGeo::Cartesian::PointImpl)
      h(value) + content_tag(:p, google_static_map2(:lat => value.y, :lng => value.x, :zoom => 12, :size => "300x150"))
    elsif value.kind_of?(RGeo::Cartesian::PolygonImpl)
      h(value)
    elsif value.kind_of?(NilClass)
      content_tag(:p, "empty", :class => "quiet")
    elsif value.kind_of?(String)
      h(value)
    else
      h(value.inspect)
    end
  end

  def attribute_table(model)
    content_tag(:table, :class => "scraper_fields") do
      model.class.attribute_names.map do |name|
        content_tag(:tr) do
          content_tag(:td, h(name), :class => "field") + content_tag(:td, attribute_value(model.attributes[name]))
        end
      end.join.html_safe
    end
  end
end
