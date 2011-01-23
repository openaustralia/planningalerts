module Typus

  module QuickEdit

    def quick_edit

      render :text => '' and return unless session[:typus_user_id]

      links = [[ "Dashboard", admin_dashboard_path ]]
      links << [ params[:message], "/admin/#{params[:path]}" ] if params[:message] && params[:path]

      options = links.reverse.map do |link|
                  "<li><a href=\"#{link.last}\">#{link.first}</a></li>"
                end

      content = <<-HTML
var links = '';
links += '<div id="quick_edit">';
links += '<ul>';
links += '#{options}';
links += '</ul>';
links += '</div>';
links += '<style type="text/css">';
links += '<!--';
links += '#quick_edit { font-size: 12px; font-family: sans-serif; position: absolute; top: 0px; right: 0px; margin: 10px; }';
links += '#quick_edit a { color: #FFF; font-weight: bold; text-decoration: none; }'
links += '#quick_edit ul { margin: 0; padding: 0; }';
links += '#quick_edit li { display: inline; background: #000; margin: 0 0 0 5px; padding: 3px 5px; }';
links += '-->';
links += '</style>';
document.write(links);
      HTML

      render :text => content

    end

  end

end