{include file="header.tpl"}

    <h3>PlanningAlerts.com API</h3>
    <p>
	    Planning application data is available programmatically as <a href="http://georss.org/">GeoRSS</a> feeds which can be used in most web mapping APIs and desktop GIS software like <a href="http://mapufacture.com">mapufacture</a> and <a href="http://pipes.yahoo.com/">Yahoo Pipes</a>. Details of the API are listed below.
	<p/>

    <h4>API documentation</h4>
    
    <!--Address-->
    <div class="apiitem">
        <h5>Single Location by address</h5>
        <p class="apidefinition">
    	   Return applications near a given street address. The area included is a square of the given size (in metres) with the address at its center. Suggested sizes are 400, 800 or 4000 metres.
    	</p>
        <code>
    	http://www.planningalerts.com/api.php?<strong>call</strong>=address<br/>&<strong>address</strong>=[some address]&<strong>area_size</strong>=[size in metres]</em>
    	</code>
    	<p class="apiexamples">
    	    <a href="http://www.planningalerts.com/api.php?call=address&address=24+Bruce+Road+Glenbrook+NSW+2773&area_size=4000">view example</a>
    	    <a href="http://maps.google.com/maps?f=q&hl=en&q=http://www.planningalerts.com/api.php%3Flat%3D51.52277%26lng%3D-0.067281%26area_size%3Dl&layer=&ie=UTF8&z=13&om=1">view on a map</a>
        </p>
    </div>
	
	<!--Single-->
	<div class="apiitem">
    	<h5>Single Location by longitude/latitude</h5>
    	<p class="apidefinition">
    	   Return applications near a given longitude/latitude. The area included is a square of the given size (in metres) with the longitude/latitude at its center. Suggested sizes are 400, 800 or 4000 metres.
    	</p>
    	<code>
    	http://www.planningalerts.com/api.php?<strong>call</strong>=point<br/>&<strong>lat</strong>=[some latitude]&<strong>lng</strong>=[some longitude]<strong>area_size</strong>=[size in metres]
    	</code>
    	<p class="apiexamples">
    	    <a href="http://www.planningalerts.com/api.php?call=point&lat=51.52277&lng=-0.067281&area_size=l">view example</a>
    	    <a href="http://maps.google.com/maps?f=q&hl=en&q=http://www.planningalerts.com/api.php%3Fcall%3Dpoint%26lat%3D51.52277%26lng%3D-0.067281%26area_size%3Dl&layer=&ie=UTF8&z=13&om=1">view on a map</a>
        </p>
    </div>
    
    <!--Box-->
	<div class="apiitem">
    	<h5>Area by longitude/latitude</h5>
    	<p class="apidefinition">
    	   Return applications within a rectangle defined by longitude/latitude.
    	</p>
    	<code>
    	http://www.planningalerts.com/api.php?<strong>call</strong>=area<br/>&<strong>bottom_left_lat</strong>=[some latitude]&<strong>bottom_left_lng</strong>=[some longitude]&<strong>top_right_lat</strong>=[some latitude]&<strong>top_right_lng</strong>=[some longitude]
    	</code>
    	<p class="apiexamples">
    	    <a href="http://www.planningalerts.com/api.php?call=area&bottom_left_lat=51.52277&bottom_left_lng=-0.067281&top_right_lat=52.52277&top_right_lng=15">view example</a>
    	    <a href="http://maps.google.com/maps?f=q&hl=en&q=http://www.planningalerts.com/api.php%3Fcall%3Darea%26bottom_left_lat%3D51.52277%26bottom_left_lng%3D-0.067281%26top_right_lat%3D52.52277%26top_right_lng%3D15&layer=&ie=UTF8&z=8&om=1">view on a map</a>
        </p>
    </div>
    
    <!--Box-->
	<div class="apiitem">
    	<h5>Planning authority</h5>
    	<p class="apidefinition">
    	   Return applications for a specific planning authority (e.g. a local council) by authority short name.
    	</p>
    	<code>
    	http://www.planningalerts.com/api.php?<strong>call</strong>=authority<br/>&<strong>authority</strong>=[some name]
    	</code>
    	<p class="apiexamples">
    	    <a href="http://www.planningalerts.com/api.php?call=authority&authority=Scottish%20Borders">view example</a>
    	    <a href="http://maps.google.com/maps?f=q&hl=en&q=http://www.planningalerts.com/api.php%3Fcall%3Dauthority%26authority%3DScottish%2520Borders&layer=&ie=UTF8&z=8&om=1">view on a map</a>
        </p>
    </div>
	

    <h4 id="hLicenseInfo">License information</h4>
    <p>
        A <a href="http://www.planningalerts.com/backup.gz"> copy of the Planning Alerts database</a> is made available under the <a href="http://opendatacommons.org/licenses/odbl/1.0/">Open Database License</a>. Any rights in individual contents of the database are licensed under the <a href="http://opendatacommons.org/licenses/dbcl/1.0/">Database Contents License</a>.
        
        Data via the api is licensed under the <a href="http://creativecommons.org/licenses/by-nc/3.0/">Creative Commons Attribution-Noncommercial 3.0 license</a>.
    </p>
		
{include file="footer.tpl"}
