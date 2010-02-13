# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu
    menu_items = []
    menu_items << {:url => about_path, :content => 'About',
      :controller => "static", :action => "about"}
    menu_items << {:url => api_howto_path, :content => '<acronym title="Application programming interface">API</acronym>',
      :controller => "api", :action => "howto"}
    menu_items << {:url => get_involved_path, :content => 'Get Involved',
      :controller => "static", :action => "get_involved"}
    menu_items << {:url => faq_path, :content => '<acronym title="Frequently asked questions">FAQ</acronym>',
      :controller => "static", :action => "faq"}
    menu_items << {:url => signup_path, :content => 'Sign Up',
      :controller => "signup", :action => ["index", "check_mail", "confirmed", "unsubscribe"]}

    content_tag(:div, :id => "divMenu") do
      content_tag(:ul, :class => "collapse") do
        menu_items.map do |m|
          if m[:action].is_a?(Array)
            selected = m[:action].any?{|a| current_page?(:controller => m[:controller], :action => a) }
          else
            selected = current_page?(:controller => m[:controller], :action => m[:action])
          end
          content_tag(:li, :class => ("selected" if selected)) do
            link_to(m[:content], m[:url])
          end
        end.join
      end
    end
  end
end
