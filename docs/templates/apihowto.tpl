{include file="header.tpl"}

    <h3>PlanningAlerts.com API</h3>
        <p>
		    Planning application data is available programmatically as <a href="http://georss.org/">GeoRSS feeds</a>. GeoRSS can be used in most all web mapping APIs and desktop GIS software, and in services like <a href="http://mapufacture.com">mapufacture</a> and <a href="http://pipes.yahoo.com/">Yahoo Pipes</a>.
		<p/>

        <p>
		Construct an api request as follows.
		Either lat/lng or postcode is required. area_size is always required.<br>
		<p/>
	
		<code>
		http://www.planningalerts.com/api.php?<br>
		&nbsp;lat=[some latitude]<br>
		&nbsp;&lng=[some longitude]<br>
		&nbsp;&postcode=[some postcode]<br>
		&nbsp;&area_size=['s' 'm' or 'l']
		</code>
		
		<p>
		    <a href="http://www.planningalerts.com/api.php?lat=51.52277&lng=-0.067281&area_size=l">an example query</a>
	    </p>
		
{include file="footer.tpl"}
