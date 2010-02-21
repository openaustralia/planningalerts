module Ym4r
  module MapstractionPlugin
    class Router
      include MappingObject
      
      def initialize(callback, api, error_callback = nil, variable = "router", map = "map")
        @callback = callback
        @api = api
        @error_callback = error_callback
        @variable = variable
        @map = map
      end

      def to_html(options = {})
        no_load = options[:no_load]
        no_script_tag = options[:no_script_tag]
        no_declare = options[:no_declare]
        no_global = options[:no_global]
        no_callback = options[:no_callback]
        no_error_callback = options[:no_error_callback]
        
        html = ""
        html << "<script type=\"text/javascript\">\n" if !no_script_tag
        #put the functions in a separate javascript file to be included in the page
        html << "var #{@variable};\n" if !no_declare and !no_global
        html << "window.onload = addCodeToFunction(window.onload,function() {\n" if !no_load
        
        if !no_declare and no_global 
          html << "#{declare(@variable)}\n"
        else
          html << "#{assign_to(@variable)}\n"
        end
        
        html << "\n});\n" if !no_load

        if !no_callback
          html << "function #{@callback}(waypoints, route) {\n"
          html << "#{@map}.showRoute(route);\n"
          html << "}\n"
        end
        if !no_error_callback
          html << "function #{@error_callback}() {\n"
          html << "alert(\"Error calculating route!!!\");\n"
          html << "}\n"
        end
        
        html << "</script>" if !no_script_tag
        html
      end

      def create
        "new MapstractionRouter(#{@callback}, \"#{@api.to_s}\", #{@error_callback})"
      end
    end
  end
end
