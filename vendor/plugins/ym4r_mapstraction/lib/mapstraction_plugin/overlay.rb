module Ym4r
  module MapstractionPlugin
    #A graphical marker positionned through geographic ccoordinates (in the WGS84 datum). An HTML info window can be set to be displayed when the marker is clicked on. Options are <tt>:info_bubble</tt> (ex: <tt>"Hello"</tt>), <tt>:info_div</tt> (ex: <tt>["Hello","itemContent"]</tt>, the itemContent part indicating the div element where to display the info), <tt>:label</tt> (ex: <tt>"Label"</tt>) and icon (ex: <tt>"/images/icon.png"</tt>).
    class Marker
      include MappingObject
      attr_accessor :point, :options
      
      def initialize(point, options = {})
        if point.is_a?(Array)
          @point = LatLonPoint.new(point)
        else
          @point = point
        end
        @options = options
      end
      
      def create
        creation = "new Marker(#{MappingObject.javascriptify_variable(@point)})"
        if !@options.empty?
          creation = "addDataToMarker(#{creation},#{MappingObject.javascriptify_variable(@options)})"
        end
        creation
      end
    end

    #A basic Latitude/longitude point.
    class LatLonPoint 
      include MappingObject
      attr_accessor :lat,:lon
      
      def initialize(latlon)
        @lat = latlon[0]
        @lon = latlon[1]
      end
      def create
        "new LatLonPoint(#{@lat},#{@lon})"
      end
    end

    #Clustering class, to efficiently manage a large number of markers on a map
    class Clusterer
      include MappingObject
      
      attr_accessor :options, :markers
      
      def initialize(markers = [], options = {})
        @mapstraction = mapstraction
        @options = options
        @markers = markers
      end

      #To add a marker to the Clusterer before hte mapstraction.clusterer_init is called on the clusterer.
      #No effect after...
      def add_marker_init(marker)
        @markers << marker
      end
      
      def create
        "new Clusterer(#{MappingObject.javascriptify_variable(@markers)},#{MappingObject.javascriptify_variable(@options)})"
      end
    end

    class Polyline 
      include MappingObject
      attr_accessor :points, :options
      
      def initialize(points,options = {})
        @points = points
        @options = options
      end
      
      def create
        creation = "new Polyline(#{MappingObject.javascriptify_variable(@points)})"
        if !@options.empty?
          creation = "addDataToPolyline(#{creation},#{MappingObject.javascriptify_variable(@options)})"
        end
        creation
      end
    end
    
    #A rectangular bounding box, defined by its south-western and north-eastern corners.
    class BoundingBox < Struct.new(:swlat,:swlon,:nelat,:nelon)
      include MappingObject
      def create
        "new BoundingBox(#{MappingObject.javascriptify_variable(swlat)},#{MappingObject.javascriptify_variable(swlon)},#{MappingObject.javascriptify_variable(nelat)},#{MappingObject.javascriptify_variable(nelon)})"
      end
    end

    #Represents a group of Markers. The whole group can be shown on and off at once. It should be declared global at initialization time to be useful.
    class MarkerGroup
      include MappingObject
      attr_accessor :active, :markers

      def initialize(markers, active = true )
        @active = active
        @markers = markers
      end
      
      def create
        "new MarkerGroup(#{MappingObject.javascriptify_variable(@markers)},#{MappingObject.javascriptify_variable(@active)})"
      end
    end

  end
end
