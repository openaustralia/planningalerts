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

  def attribute_error_value(value)
    if value.kind_of?(Array)
      first_errored = value.find{|v| !v.valid?}
      if first_errored
        attribute_error_value(first_errored)
      else
        content_tag(:p, "&hellip;".html_safe)
      end
    elsif value.class.respond_to?(:attribute_names)
      attribute_error_table(value)
    else
      h(value)
    end
  end

  # TODO Turn this into a partial
  def attribute_error_table(model)
    content_tag(:table, :class => "scraper_fields") do
      content_tag(:tr) do
        content_tag(:th, "JSON parameters") + content_tag(:th, "Errors", :class => "error")
      end + 
      model.json_errors.map do |attr, errors|
        content_tag(:tr) do
          error_html = errors.map do |e|
            t = content_tag(:span, e.message, :class => "highlight")
            if e.spec_section
              t += " &mdash; see ".html_safe +
                link_to("section #{e.spec_section} of specification", atdis_specification_path(:anchor => "section#{e.spec_section}")) + ".".html_safe
            end
            t
          end.join(" ").html_safe
          content_tag(:td, content_tag(:pre, h(truncate(MultiJson.dump(attr, :pretty => true), :length => 500)))) +
            content_tag(:td, error_html)
        end
      end.join.html_safe
    end
  end
end
