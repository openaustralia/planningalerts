
  // A Rectangle is a simple overlay that outlines a lat/lng bounds on the
  // map. It has a border of the given weight and color and can optionally
  // have a semi-transparent background color.
  function Rectangle(bounds, opt_weight, opt_color) {
    this.bounds_ = bounds;
    this.weight_ = opt_weight || 5;
    this.color_ = opt_color || '#EF2C2C';
  }
  Rectangle.prototype = new GOverlay();

  // Creates the DIV representing this rectangle.
  Rectangle.prototype.initialize = function(map) {
    // Create the DIV representing our rectangle
    var div = document.createElement("div");
    div.style.border = this.weight_ + "px solid " + this.color_;
    div.style.position = "absolute";

    // Our rectangle is flat against the map, so we add our selves to the
    // MAP_PANE pane, which is at the same z-index as the map itself (i.e.,
    // below the marker shadows)
    map.getPane(G_MAP_MAP_PANE).appendChild(div);

    this.map_ = map;
    this.div_ = div;
  }

  // Remove the main DIV from the map pane
  Rectangle.prototype.remove = function() {
    this.div_.parentNode.removeChild(this.div_);
  }

  // Copy our data to a new Rectangle
  Rectangle.prototype.copy = function() {
    return new Rectangle(this.bounds_, this.weight_, this.color_,
                         this.backgroundColor_, this.opacity_);
  }

  // Redraw the rectangle based on the current projection and zoom level
  Rectangle.prototype.redraw = function(force) {
    // We only need to redraw if the coordinate system has changed
    if (!force) return;

    // Calculate the DIV coordinates of two opposite corners of our bounds to
    // get the size and position of our rectangle
    var c1 = this.map_.fromLatLngToDivPixel(this.bounds_.getSouthWest());
    var c2 = this.map_.fromLatLngToDivPixel(this.bounds_.getNorthEast());

    // Now position our DIV based on the DIV coordinates of our bounds
    this.div_.style.width = Math.abs(c2.x - c1.x) + "px";
    this.div_.style.height = Math.abs(c2.y - c1.y) + "px";
    this.div_.style.left = (Math.min(c2.x, c1.x) - this.weight_) + "px";
    this.div_.style.top = (Math.min(c2.y, c1.y) - this.weight_) + "px";
  }


  function load(nCenterLong, nCenterLat, nBottomLeftLong, nBottomLeftLat, TopRightLong, TopRightLat) {
    if (GBrowserIsCompatible()) {
      var map = new GMap2(document.getElementById("map"));
      map.addControl(new GSmallMapControl());
      map.addControl(new GMapTypeControl());
      map.setCenter(new GLatLng(nCenterLat, nCenterLong), 13);

      // Display a rectangle in the center of the map at about a quarter of
      // the size of the main map
      var bounds = map.getBounds();
      var southWest = bounds.getSouthWest();
      var northEast = bounds.getNorthEast();

      var rectBounds = new GLatLngBounds(
	
          new GLatLng(nBottomLeftLat,
                      nBottomLeftLong),
          new GLatLng(TopRightLat,
                      TopRightLong));
      map.addOverlay(new Rectangle(rectBounds));
    }
  }
