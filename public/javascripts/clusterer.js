// Clusterer for Mapstraction: To display a large number of markers
//
// Usage: 
//
// When you have a Mapstraction object (for example, of name mapstraction), do:
// 
// var clusterer = new Clusterer(mapstraction);
// 
// Then you must add markers to the clusterer.
//
// clusterer.addMarker(marker);
//
// By default, the clustering will start when there are more than 150 markers in the Clusterer object.
// You can pass options to the Clusterer constructor to change this behaviour.
//
// Copyright © 2005,2006 by Jef Poskanzer <jef@mail.acme.com>.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// For commentary on this license please see http://www.acme.com/license.html
//
// Modified for use with Mapstraction by Guilhem Vellut. Bugs and comments: guilhem.vellut@gmail.com

//Add a method to the Mapstraction class to add a clusterer
Mapstraction.prototype.addClusterer = function(clusterer){
    clusterer.initialize(this);
}

// Constructor.
Clusterer = function (markers, options){
    this.markers = markers || [];
    for(var i = 0, len = markers.length ; i < len ; ++i){
	markers[i].onMap = false;
    }

    this.clusters = [];
    this.timeout = null;
    
    options = options || new Object();
    this.maxVisibleMarkers = options.maxVisibleMarkers || 150; 
    this.gridSize = options.gridSize || 5;
    this.minMarkersPerCluster = options.minMarkersPerCluster ||5;
    this.maxLinesPerInfoBox = options.maxLinesPerInfoBox ||10;
    this.icon = options.icon;
    
    map.addEventListener("moveend",Clusterer.makeCaller( Clusterer.display, this ) );
   
};

// Call this to add a marker.
Clusterer.prototype.addMarker = function ( marker){
    marker.onMap = false;
    this.markers.push( marker );

    if(this.map != null){
	if ( marker.setMap != null )
	    marker.setMap( this.map );
	this.displayLater();
    }
};

Clusterer.prototype.initialize = function(mapstraction){
    this.map = mapstraction;
    this.currentZoomLevel = mapstraction.getZoom();
    for(var i = 0, len = this.markers.length; i < len; ++i ){
	this.markers[i].setMap(mapstraction);
    }
    this.displayLater();
}


// Call this to remove a marker.
Clusterer.prototype.removeMarker = function ( marker )
    {
    for ( var i = 0; i < this.markers.length; ++i )
	if ( this.markers[i] == marker )
	    {
	    if ( marker.onMap )
		this.map.removeMarker( marker );
	    for ( var j = 0; j < this.clusters.length; ++j )
		{
		var cluster = this.clusters[j];
		if ( cluster != null )
		    {
		    for ( var k = 0; k < cluster.markers.length; ++k )
			if ( cluster.markers[k] == marker )
			    {
			    cluster.markers[k] = null;
			    --cluster.markerCount;
			    break;
			    }
		    if ( cluster.markerCount == 0 )
			{
			this.clearCluster( cluster );
			this.clusters[j] = null;
			}
		    }
	       }
	    this.markers[i] = null;
	    break;
	    }
    this.displayLater();
 
    };


Clusterer.prototype.displayLater = function ()
    {
    if ( this.timeout != null )
	clearTimeout( this.timeout );
    this.timeout = setTimeout( Clusterer.makeCaller( Clusterer.display, this ), 50 );
    };


Clusterer.display = function ( clusterer )
    {
    var i, j, marker, cluster;

    clearTimeout( clusterer.timeout );

    var newZoomLevel = clusterer.map.getZoom();
    if ( newZoomLevel != clusterer.currentZoomLevel )
	{
	// When the zoom level changes, we have to remove all the clusters.
	for ( i = 0; i < clusterer.clusters.length; ++i )
	    if ( clusterer.clusters[i] != null )
		{
		clusterer.clearCluster( clusterer.clusters[i] );
		clusterer.clusters[i] = null;
		}
	clusterer.clusters.length = 0;
	clusterer.currentZoomLevel = newZoomLevel;
	}

    // Get the current bounds of the visible area.
    var bounds = clusterer.map.getBounds();

    // Expand the bounds a little, so things look smoother when scrolling
    // by small amounts.
    var sw = bounds.getSouthWest();
    var ne = bounds.getNorthEast();
    var dx = ne.lon - sw.lon;
    var dy = ne.lat - sw.lat;

    dx *= 0.10;
    dy *= 0.10;
    bounds = new BoundingBox(sw.lat - dy, sw.lon - dx,ne.lat + dy, ne.lon + dx);
   

    // Partition the markers into visible and non-visible lists.
    var visibleMarkers = [];
    var nonvisibleMarkers = [];
    for ( i = 0; i < clusterer.markers.length; ++i )
	{
	marker = clusterer.markers[i];
	if ( marker != null )
	    if ( bounds.contains( marker.location ) )
		visibleMarkers.push( marker );
	    else
		nonvisibleMarkers.push( marker );
	}

    // Take down the non-visible markers.
    for ( i = 0; i < nonvisibleMarkers.length; ++i )
	{
	marker = nonvisibleMarkers[i];
	if ( marker.onMap )
	    {
	    clusterer.map.removeMarker( marker );
	    marker.onMap = false;
	    }
	}

    // Take down the non-visible clusters.
    for ( i = 0; i < clusterer.clusters.length; ++i )
	{
	cluster = clusterer.clusters[i];
	if ( cluster != null && ! bounds.contains( cluster.marker.location ) && cluster.onMap )
	    {
	    clusterer.map.removeMarker( cluster.marker );
	    cluster.onMap = false;
	    }
	}

    // Clustering!  This is some complicated stuff.  We have three goals
    // here.  One, limit the number of markers & clusters displayed, so the
    // maps code doesn't slow to a crawl.  Two, when possible keep existing
    // clusters instead of replacing them with new ones, so that the app pans
    // better.  And three, of course, be CPU and memory efficient.
    if ( visibleMarkers.length > clusterer.maxVisibleMarkers )
	{
	// Add to the list of clusters by splitting up the current bounds
	// into a grid.
	var latRange = bounds.getNorthEast().lat - bounds.getSouthWest().lat;
	var latInc = latRange / clusterer.gridSize;
	var lngInc = latInc / Math.cos( ( bounds.getNorthEast().lat + bounds.getSouthWest().lat ) / 2.0 * Math.PI / 180.0 );
	for ( var lat = bounds.getSouthWest().lat; lat <= bounds.getNorthEast().lat; lat += latInc )
	    for ( var lng = bounds.getSouthWest().lng; lng <= bounds.getNorthEast().lng; lng += lngInc )
		{
		cluster = new Object();
		cluster.clusterer = clusterer;
		cluster.bounds = new BoundingBox( lat, lng , lat + latInc, lng + lngInc  );
		cluster.markers = [];
		cluster.markerCount = 0;
		cluster.onMap = false;
		cluster.marker = null;
		clusterer.clusters.push( cluster );
		}

	// Put all the unclustered visible markers into a cluster - the first
	// one it fits in, which favors pre-existing clusters.
	for ( i = 0; i < visibleMarkers.length; ++i )
	    {
	    marker = visibleMarkers[i];
	    if ( marker != null && ! marker.inCluster )
		{
		for ( j = 0; j < clusterer.clusters.length; ++j )
		    {
		    cluster = clusterer.clusters[j];
		    if ( cluster != null && cluster.bounds.contains( marker.location ) )
			{
			cluster.markers.push( marker );
			++cluster.markerCount;
			marker.inCluster = true;
			}
		    }
		}
	    }

	// Get rid of any clusters containing only a few markers.
	for ( i = 0; i < clusterer.clusters.length; ++i )
	    if ( clusterer.clusters[i] != null && clusterer.clusters[i].markerCount < clusterer.minMarkersPerCluster )
		{
		clusterer.clearCluster( clusterer.clusters[i] );
		clusterer.clusters[i] = null;
		}

	// Shrink the clusters list.
	for ( i = clusterer.clusters.length - 1; i >= 0; --i )
	    if ( clusterer.clusters[i] != null )
		break;
	    else
		--clusterer.clusters.length;

	// Ok, we have our clusters.  Go through the markers in each
	// cluster and remove them from the map if they are currently up.
	for ( i = 0; i < clusterer.clusters.length; ++i )
	    {
	    cluster = clusterer.clusters[i];
	    if ( cluster != null )
		{
		for ( j = 0; j < cluster.markers.length; ++j )
		    {
		    marker = cluster.markers[j];
		    if ( marker != null && marker.onMap )
			{
			clusterer.map.removeMarker( marker );
			marker.onMap = false;
			}
		    }
		}
	    }

	// Now make cluster-markers for any clusters that need one.
	for ( i = 0; i < clusterer.clusters.length; ++i )
	    {
	    cluster = clusterer.clusters[i];
	    if ( cluster != null && cluster.marker == null )
		{
		// Figure out the average coordinates of the markers in this
		// cluster.
		var xTotal = 0.0, yTotal = 0.0;
		for ( j = 0; j < cluster.markers.length; ++j )
		    {
		    marker = cluster.markers[j];
		    if ( marker != null )
			{
			xTotal += ( + marker.location.lng );
			yTotal += ( + marker.location.lat );
			}
		    }
		var location = new LatLonPoint( yTotal / cluster.markerCount, xTotal / cluster.markerCount );
		marker = new Marker( location);
		if(clusterer.icon)
		    marker.setIcon(clusterer.icon);
		marker.setInfoBubble(Clusterer.popUpText(cluster));
		cluster.marker = marker;
		}
	    }
	}

    // Display the visible markers not already up and not in clusters.
    for ( i = 0; i < visibleMarkers.length; ++i )
	{
	marker = visibleMarkers[i];
	if ( marker != null && ! marker.onMap && ! marker.inCluster )
	    {
	    clusterer.map.addMarker( marker );
	    if ( marker.addedToMap != null )
		marker.addedToMap();
	    marker.onMap = true;
	    }
	}

    // Display the visible clusters not already up.
    for ( i = 0; i < clusterer.clusters.length; ++i )
	{
	cluster = clusterer.clusters[i];
	if ( cluster != null && ! cluster.onMap && bounds.contains( cluster.marker.location ) )
	    {
	    clusterer.map.addMarker( cluster.marker );
	    cluster.onMap = true;
	    }
	}
 };


Clusterer.popUpText = function (cluster)
    {
    var clusterer = cluster.clusterer;
    var html = '<table width="300">';
    var n = 0;
    for ( var i = 0; i < cluster.markers.length; ++i )
	{
	var marker = cluster.markers[i];
	if ( marker != null )
	    {
	    ++n;
	    html += '<tr>';
	    html += '<td>' ;
	    if( marker.labelText != null)
		html += marker.labelText;
	    else
		html += 'marker #' + i;
	    if(marker.iconUrl != null){
		html += '<td><img src="' + marker.iconUrl + '" /></td>';
	    }
	    html += '</td></tr>';
	    if ( n == clusterer.maxLinesPerInfoBox - 1 && cluster.markerCount > clusterer.maxLinesPerInfoBox  )
		{
		html += '<tr><td colspan="2">...and ' + ( cluster.markerCount - n ) + ' more</td></tr>';
		break;
		}
	    }
	}
    html += '</table>';

    return html;
};

Clusterer.prototype.clearCluster = function ( cluster )
    {
    var i, marker;

    for ( i = 0; i < cluster.markers.length; ++i )
	if ( cluster.markers[i] != null )
	    {
	    cluster.markers[i].inCluster = false;
	    cluster.markers[i] = null;
	    }
    cluster.markers.length = 0;
    cluster.markerCount = 0;
    if ( cluster.onMap )
	{
	this.map.removeMarker( cluster.marker );
	cluster.onMap = false;
	}
    };


// This returns a function closure that calls the given routine with the
// specified arg.
Clusterer.makeCaller = function ( func, arg )
    {
    return function () { func( arg ); };
    };


// Augment GMarker so it handles markers that have been created but
// not yet addOverlayed.

Marker.prototype.setMap = function ( map )
    {
    this.map = map;
    };

Marker.prototype.addedToMap = function ()
    {
    this.map = null;
    };
