module AuthoritiesHelper
  def attribute_value(value)
    if value.class.respond_to?(:attribute_names)
      attribute_table(value)
    else
      h(value)
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
