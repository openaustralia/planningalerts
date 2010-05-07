# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def page_matches?(options)
    if options[:action].is_a?(Array)
      options[:action].any?{|a| current_page?(:controller => options[:controller], :action => a) }
    else
      current_page?(:controller => options[:controller], :action => options[:action])
    end
  end
  
  def li_selected(m)
    content_tag(:li, :class => ("selected" if page_matches?(m))) do
      yield
    end
  end

  def meters_in_words(meters)
    if meters < 1000
      "#{meters} m"
    else
      km = meters / 1000.0
      text = "%.1f" % km
      # Make 2000 m appear as 2 km rather than 2.0 km
      if text [-2..-1] == ".0"
        text = text[0..-3]
      end
      "#{text} km"
    end
  end
  
  def is_mobile_optimised?
    @mobile_optimised == true
  end
  
  def mobile_switcher_links
    if is_mobile_optimised? && is_mobile_device?
      link_to_unless(in_mobile_view?, "Mobile", :mobile => "true") + " | " + link_to_unless(!in_mobile_view?, "Classic", :mobile => "false")
    end
  end
end
