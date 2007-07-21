<?php

    require_once ("config.php"); 
    
 $xml = safe_scrape_page('http://www.wansbeck.gov.uk/planning.cfm?day=17&month=7&year=2007');

$parsed_applications = simplexml_load_string($xml);

//Loop through the applications, add tinyurl / google maps etc and add to array
if(sizeof($parsed_applications) >0){
    foreach($parsed_applications->applications->application as $parsed_application){

}

}

print "ddd";
	

?>