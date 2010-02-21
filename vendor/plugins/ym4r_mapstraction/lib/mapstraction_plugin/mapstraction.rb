module Ym4r
  module MapstractionPlugin 

    #Map types of the map
    class MapType
      ROAD = Variable.new("Mapstraction.ROAD")
      SATELLITE = Variable.new("Mapstraction.SATELLITE")
      HYBRID = Variable.new("Mapstraction.HYBRID")
    end

    #Represents a Mapstracted map.
    class Mapstraction
      include MappingObject
                  
      #The id of the DIV that will contain the map in the HTML page. 
      attr_reader :container, :map_type

      #A constant containing the declaration of the VML namespace, necessary to display polylines in google maps under IE.
      VML_NAMESPACE = "xmlns:v=\"urn:schemas-microsoft-com:vml\""

      #By default the map in the HTML page will be globally accessible with the name +map+. +map_type+ is one of three choices: <tt>:google</tt>, <tt>:yahoo</tt> or <tt>microsoft</tt>.
      def initialize(container, map_type, variable = "map")
        @container = container
        @map_type = map_type
        @variable = variable
        @init = []
        @init_begin = []
        @init_end = []
        @global_init = []
      end
      
      def self.header(types,options = {})
        a = ""
        Array(types).each do |type|
          if type == :google || type == :openstreetmap
            options[:with_vml] = true unless options.has_key?(:with_vml)
            if options.has_key?(:key)
              api_key = options[:key]
            elsif GMAPS_API_KEY.is_a?(Hash)
              #For this environment, multiple hosts are possible.
              #:host must have been passed as option
              if options.has_key?(:host)
                api_key = GMAPS_API_KEY[options[:host]]
              else
                raise AmbiguousGMapsAPIKeyException.new(GMAPS_API_KEY.keys.join(","))
              end
            else
              #Only one possible key: take it
              api_key = GMAPS_API_KEY
            end
            a << "<script src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{api_key}\" type=\"text/javascript\"></script>\n"
            a << "<style type=\"text/css\">\n v\:* { behavior:url(#default#VML);}\n</style>" if options[:with_vml]
          elsif type == :yahoo
            a << "<script type=\"text/javascript\" src=\"http://api.maps.yahoo.com/ajaxymap?v=3.4&amp;appid=YellowMasp4R\"></script>\n"
          elsif type == :microsoft
            a << "<script src=\"http://dev.virtualearth.net/mapcontrol/v3/mapcontrol.js\"></script>\n"
          elsif type == :map24
            if options.has_key?(:key)
              api_key = options[:key]
            elsif MAP24_API_KEY.is_a?(Hash)
              #For this environment, multiple hosts are possible.
              #:host must have been passed as option
              if options.has_key?(:host)
                api_key = MAP24_API_KEY[options[:host]]
              else
                raise AmbiguousMap24APIKeyException.new(MAP24_API_KEY.keys.join(","))
              end
            else
              #Only one possible key: take it
              api_key = MAP24_API_KEY
            end
            a << "<script type=\"text/javascript\" language=\"javascript\" src=\"http://api.maptp.map24.com/ajax?appkey=#{api_key}\"></script>\n"
          elsif type == :multimap
            if options.has_key?(:key)
              api_key = options[:key]
            elsif MULTIMAP_API_KEY.is_a?(Hash)
              #For this environment, multiple hosts are possible.
              #:host must have been passed as option
              if options.has_key?(:host)
                api_key = MULTIMAP_API_KEY[options[:host]]
              else
                raise AmbiguousMultimapAPIKeyException.new(MULTIMAP_API_KEY.keys.join(","))
              end
            else
              #Only one possible key: take it
              api_key = MULTIMAP_API_KEY
            end
            a << "<script type=\"text/javascript\" src=\"http://developer.multimap.com/API/maps/1.2/#{api_key}\"></script>\n"
          elsif type == :mapquest
            if options.has_key?(:key)
              api_key = options[:key]
            elsif MAPQUEST_API_KEY.is_a?(Hash)
              #For this environment, multiple hosts are possible.
              #:host must have been passed as option
              if options.has_key?(:host)
                api_key = MAPQUEST_API_KEY[options[:host]]
              else
                raise AmbiguousMapquestAPIKeyException.new(MAPQUEST_API_KEY.keys.join(","))
              end
            else
              #Only one possible key: take it
              api_key = MAPQUEST_API_KEY
            end
            a << "<script src=\"http://btilelog.access.mapquest.com/tilelog/transaction?transaction=script&amp;key=#{api_key}&amp;ipr=true&amp;itk=true&amp;v=5.2.0\" type=\"text/javascript\"></script>\n"
            a << "<!-- The JSAPI Source files (only needed for geocoding & routing with MapQuest) -->\n"
            a << "<script src=\"/javascripts/mapquest-js/mqcommon.js\" type=\"text/javascript\"></script>\n"
            a << "<script src=\"/javascripts/mapquest-js/mqutils.js\" type=\"text/javascript\"></script>\n"
            a << "<script src=\"/javascripts/mapquest-js/mqobjects.js\" type=\"text/javascript\"></script>\n"
            a << "<script src=\"/javascripts/mapquest-js/mqexec.js\" type=\"text/javascript\"></script>\n"
          elsif type == :freeearth
            a << "<script type=\"text/javascript\" src=\"http://freeearth.poly9.com/api.js\"></script>\n"
          elsif type == :openlayers
            a << "<script src=\"http://openlayers.org/api/OpenLayers.js\"></script>\n"
          end
        end
        a << "<script src=\"/javascripts/mapstraction.js\" type=\"text/javascript\"></script>\n"
        a << "<script src=\"/javascripts/mapstraction-route.js\" type=\"text/javascript\"></script>\n"
        a << "<script src=\"/javascripts/ym4r-mapstraction.js\" type=\"text/javascript\"></script>\n"
        a
      end
     
      #Outputs the <div id=...></div> which has been configured to contain the map. You can pass <tt>:width</tt> and <tt>:height</tt> as options to output this in the style attribute of the DIV element (you could also achieve the same effect by putting the dimension info into a CSS or using the instance method Mapstraction#header_width_height)
      def div(options = {})
        attributes = "id=\"#{@container}\" "
        if options.has_key?(:height) && options.has_key?(:width)
          attributes += "style=\"width:#{options[:width]}px;height:#{options[:height]}px\""
        end
        "<div #{attributes}></div>"
      end

      #Outputs a style declaration setting the dimensions of the DIV container of the map. This info can also be set manually in a CSS.
      def header_width_height(width,height)
        "<style type=\"text/css\">\n##{@container} { height: #{height}px;\n  width: #{width}px;\n}\n</style>"
      end

      #Records arbitrary JavaScript code and outputs it during initialization inside the +load+ function.
      def record_init(code)
        @init << code
      end

      #Initializes the controls: you can pass a hash with key <tt>:small</tt> (only one for now) and a boolean value as the value (usually true, since the control is not displayed by default). Also in later version, you can be a bit more precise, with the following keys: pan (boolean), zoom (:large or :small), overview (boolean), scale (boolean), map_type (boolean)
      def control_init(controls = {})
        if controls[:small]
          @init << add_small_controls()
        elsif controls[:large]
          @init << add_large_controls()
        else
          @init << add_controls(controls)
        end
      end

      #Initializes the initial center and zoom of the map. +center+ can be both a GLatLng object or a 2-float array.
      def center_zoom_init(center, zoom)
        if center.is_a?(LatLonPoint)
          @init_begin << set_center_and_zoom(center,zoom)
        else
          @init_begin << set_center_and_zoom(LatLonPoint.new(center),zoom)
        end
      end

      #Center and zoom based on the bbox corners. Pass a GLatLngBounds object, an array of 2D coordinates (sw and ne) or an array of GLatLng objects (sw and ne).
      def center_zoom_on_bounds_init(bounds)
        if bounds.is_a?(Array)
          if bounds[0].is_a?(Array)
            bounds = BoundingBox.new(bounds[0][0],bounds[0][1],bounds[1][0],bounds[1][1])
          elsif bounds[0].is_a?(LatLonPoint)
            bounds = BoundingBox.new(bounds[0].lat,bounds[0].lon,bounds[1].lat,bounds[1].lon)
          end
        end
        #else it is already a latlngbounds object

        @init_begin << set_bounds(bounds)
      end

      #Initializes the map by adding a marker
      def marker_init(marker, options = {})
        if options[:open_bubble]
          @init << add_marker_and_open(marker)
        else
          @init << add_marker(marker)
        end
      end

      def marker_group_init(marker_group)
        @init << add_marker_group(marker_group)
      end

      def clusterer_init(clusterer)
        @init << add_clusterer(clusterer)
      end

      def polyline_init(polyline)
        @init << add_polyline(polyline)
      end

      #Sets the map type displayed by default after the map is loaded.
      def set_map_type_init(map_type)
        @init << set_map_type(map_type)
      end

      #Locally declare a MappingObject with variable name "name"
      def declare_init(variable, name)
        @init << variable.declare(name)
      end

      #Records arbitrary JavaScript code and outputs it during initialization outside the +load+ function (ie globally).
      def record_global_init(code)
        @global_init << code
      end

       #Registers an event
      def event_init(object,event,callback)
        @init << "#{object.to_javascript}.addEventListener(\"#{MappingObject.javascriptify_method(event.to_s)}\",#{callback})"
      end

      #Registers an event globally
      def event_global_init(object,event,callback)
        @global_init << "#{object.to_javascript}.addEventListener(\"#{MappingObject.javascriptify_method(event.to_s)}\",#{callback})"
      end
            
      #Declares the marker globally with name +name+
      def marker_global_init(marker,name, options = {})
        declare_global_init(marker,name)
        marker_init(marker,options)
      end

      #Declares the marker group globally with name +name+
      def marker_group_global_init(marker_group,name)
        declare_global_init(marker_group,name)
        marker_group_init(marker_group)
      end

      def clusterer_global_init(clusterer,name)
        declare_global_init(clusterer,name)
        clusterer_init(clusterer)
      end

      def polyline_global_init(polyline, name)
        declare_global_init(polyline,name)
        polyline_init(clusterer)
      end

      #Globally declare a MappingObject with variable name "name"
      def declare_global_init(variable,name)
        @global_init << variable.declare(name)
      end
      
      #Outputs the initialization code for the map. By default, it outputs the script tags, performs the initialization in response to the onload event of the window and makes the map globally available. You can pass the <tt>:full => true</tt> option to setup fullscreen for the map.
      def to_html(options = {})
        no_load = options[:no_load]
        no_script_tag = options[:no_script_tag]
        no_declare = options[:no_declare]
        no_global = options[:no_global]
        fullscreen = options[:full]
        
        html = ""
        html << "<script type=\"text/javascript\">\n" if !no_script_tag
        #put the functions in a separate javascript file to be included in the page
        html << @global_init * "\n"
        html << "var #{@variable};\n" if !no_declare and !no_global
        html << "window.onload = addCodeToFunction(window.onload,function() {\n" if !no_load
        
        if fullscreen
          #Adding the initial resizing and setting up the event handler for
          #future resizes
          html << "setWindowDims($('#{@container}'));\n"
          html << "if (window.attachEvent) { window.attachEvent(\"onresize\", function() {setWindowDims($('#{@container}'));})} else {window.addEventListener(\"resize\", function() {setWindowDims($('#{@container}')); } , false);}\n"
        end

        if !no_declare and no_global 
          html << "#{declare(@variable)}\n"
        else
          html << "#{assign_to(@variable)}\n"
        end
                
        html << @init_begin * "\n"
        html << @init * "\n"
        html << @init_end * "\n"
        html << "\n});\n" if !no_load
        html << "</script>" if !no_script_tag
        
        if fullscreen
          #setting up the style in case of full screen
          html << "<style>html, body {width: 100%; height: 100%} body {margin:0} ##{@container} {margin:0} </style>"
        end
                
        html
      end

      #Outputs in JavaScript the creation of a Mapstraction object 
      def create
        "new Mapstraction(\"#{@container}\",\"#{@map_type.to_s}\")"
      end
    end

    class AmbiguousGMapsAPIKeyException < StandardError
    end

    class AmbiguousMap24APIKeyException < StandardError
    end
    
    class AmbiguousMapquestAPIKeyException < StandardError
    end
  
    class AmbiguousMultimapAPIKeyException < StandardError
    end
  end
end

