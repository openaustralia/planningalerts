{include file="header.tpl"}

    <h3>PlanningAlerts.org.au API</h3>
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
    	{$api_url}?<strong>call</strong>=address<br/>&<strong>address</strong>=[some address]&<strong>area_size</strong>=[size in metres]</em>
    	</code>
    	<p class="apiexamples">
    	    <a href="{$api_example_address_url}">view example</a>
    	    <a href="{$map_example_address_url}">view on a map</a>
        </p>
    </div>
	
	<!--Single-->
	<div class="apiitem">
    	<h5>Single Location by longitude/latitude</h5>
    	<p class="apidefinition">
    	   Return applications near a given longitude/latitude. The area included is a square of the given size (in metres) with the longitude/latitude at its center. Suggested sizes are 400, 800 or 4000 metres.
    	</p>
    	<code>
    	{$api_url}?<strong>call</strong>=point<br/>&<strong>lat</strong>=[some latitude]&<strong>lng</strong>=[some longitude]<strong>area_size</strong>=[size in metres]
    	</code>
    	<p class="apiexamples">
    	    <a href="{$api_example_latlong_url}">view example</a>
    	    <a href="{$map_example_latlong_url}">view on a map</a>
        </p>
    </div>
    
    <!--Area-->
	<div class="apiitem">
    	<h5>Area by longitude/latitude</h5>
    	<p class="apidefinition">
    	   Return applications within a rectangle defined by longitude/latitude.
    	</p>
    	<code>
    	{$api_url}?<strong>call</strong>=area<br/>&<strong>bottom_left_lat</strong>=[some latitude]&<strong>bottom_left_lng</strong>=[some longitude]&<strong>top_right_lat</strong>=[some latitude]&<strong>top_right_lng</strong>=[some longitude]
    	</code>
    	<p class="apiexamples">
    	    <a href="{$api_example_area_url}">view example</a>
    	    <a href="{$map_example_area_url}">view on a map</a>
        </p>
    </div>
    
    <!--Authority-->
	<div class="apiitem">
    	<h5>Planning authority</h5>
    	<p class="apidefinition">
    	   Return applications for a specific planning authority (e.g. a local council) by authority short name.
    	</p>
    	<code>
    	{$api_url}?<strong>call</strong>=authority<br/>&<strong>authority</strong>=[some name]
    	</code>
    	<p class="apiexamples">
    	    <a href="{$api_example_authority_url}">view example</a>
    	    <a href="{$map_example_authority_url}">view on a map</a>
        </p>
    </div>
	

    <h4 id="hLicenseInfo">License information</h4>
    <p>
        Data via the api is licensed under the <a href="http://creativecommons.org/licenses/by-nc/3.0/">Creative Commons Attribution-Noncommercial 3.0 license</a>.
    </p>
		
{include file="footer.tpl"}
