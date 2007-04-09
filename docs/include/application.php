<?php

require_once('config.php');
require_once('DB.php');

class Application{
    var $authority_id = 0;
	var $council_reference = "";
	var $date_recieved = "";
	var $date_scraped ="";
	var $address = "";
	var $postcode = "";
	var $description = "";
	var $status = "";
	var $info_url = "";
	var $info_tinyurl = "";    	
	var $comment_url = "";
	var $comment_tinyurl = "";
	var $map_url = "";
	var $x = 0;
	var $y = 0;

	#lat/lon used by rss.tpl, not yet in schema
	var $lat = 0;
	var $lon = 0;

	#authority name in join'd table 'authority'
    var $authority_name = "";            	
	
	function exists(){
        
        $db = DB::connect(DB_CONNECTION_STRING);
        
        $exists = false;
        $council_reference = $db->quote($this->council_reference);   
        $authority_id = $db->quote($this->authority_id);    	    
        
        $sql = "select application_id 
            from application 
            where council_reference = $council_reference
                and authority_id = $authority_id";

        if(sizeof($db->getAll($sql)) >0){
            $exists = true;
        }
        return $exists;
    }
	
    //Save
    function save(){
     
          $db = DB::connect(DB_CONNECTION_STRING);
             
          $council_reference = $db->quote($this->council_reference);
          $address = $db->quote($this->address);
          $postcode = $db->quote($this->postcode);              
          $description = $db->quote($this->description);
          $info_url = $db->quote($this->info_url);
          $info_tinyurl = $db->quote($this->info_tinyurl);              
          $comment_url = $db->quote($this->comment_url);
          $comment_tinyurl = $db->quote($this->comment_tinyurl);
          $authority_id = $db->quote($this->authority_id);                                                        
          $x = $db->quote($this->x);     
          $y = $db->quote($this->y);     
          $date_scraped = $db->quote($this->date_scraped);     
          $map_url = $db->quote($this->map_url);                                               

        $sql ="insert into application 
            (
            council_reference,
            address,
            postcode,
            description,
            info_url,
            info_tinyurl,
            comment_url,
            comment_tinyurl,
            authority_id,
            x,
            y,
            date_scraped,
            map_url
            )
            values(
            $council_reference,
            $address,
            $postcode,
            $description,
            $info_url,
            $info_tinyurl,
            $comment_url,
            $comment_tinyurl,
            $authority_id,
            $x,
            $y,
            $date_scraped,
            $map_url
            )";
            
            $db->query($sql);

    }

}

class Applications{

    //by point
	function query($x,$y,$d) {
		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, postcode, description, info_url, comment_url, map_url, x, y, date_recieved, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					where application.x > " . $db->quote($x - $d) . " and application.x < " . $db->quote($x + $d) .
						" and application.y > " . $db->quote($y - $d) . " and application.y < " . $db->quote($y + $d) .
					" order by date_scraped desc limit 100";
		$application_results = $db->getAll($sql);			
		return applications::load_applications($application_results);
	}
	
	//by area
	function query_area($x1,$y1,$x2,$y2) {

		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, postcode, description, info_url, comment_url, map_url, x, y, date_recieved, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					where application.x > " . $db->quote($x1) . " and application.x < " . $db->quote($x2) .
						" and application.y > " . $db->quote($y1) . " and application.y < " . $db->quote($y2) .
					" order by date_scraped desc limit 100";

		$application_results = $db->getAll($sql);			
		return applications::load_applications($application_results);
	}
	
	//by authority
	function query_authority($authority_short_name) {
		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, postcode, description, info_url, comment_url, map_url, x, y, date_recieved, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					where authority.short_name = " . $db->quote($authority_short_name) ." order by date_scraped desc limit 100";

			$application_results = $db->getAll($sql);			
			return applications::load_applications($application_results);
	}
	
	function load_applications($application_results){
	    $applications = array();
		if (sizeof($application_results) > 0) {
			for ($i=0; $i < sizeof($application_results); $i++) {
				$application = new application();
				$application->council_reference = $application_results[$i][0];
				$application->address = $application_results[$i][1];
				$application->postcode = $application_results[$i][2];
				$application->description = $application_results[$i][3];
				$application->info_url = $application_results[$i][4];
				$application->comment_url = $application_results[$i][5];
				$application->map_url = $application_results[$i][6];
				$application->x = $application_results[$i][7];
				$application->y  = $application_results[$i][8];
				$application->date_received = $application_results[$i][9];
				$application->authority_name  = $application_results[$i][10];

				$os = new OSRef($application->x, $application->y);
				$latlng = $os->toLatLng();
				$application->lat = $latlng->lat;
				$application->lon = $latlng->lng;
				array_push($applications, $application);
			}
		}
		
		return $applications;
	}
}

?>
