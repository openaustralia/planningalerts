<?php

require_once('config.php');
require_once('DB.php');

class Application{
    var $authority_id = 0;
	var $council_reference = "";
	var $date_received = "";
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
	var $lat = 0;
	var $lng = 0;

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
          $lat = $db->quote($this->lat);     
          $lng = $db->quote($this->lng);     
          $date_scraped = $db->quote($this->date_scraped);     
          $date_received = $db->quote($this->date_received);     
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
            lat,
            lng,
            date_scraped,
            date_recieved,
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
            $lat,
            $lng,
            $date_scraped,
            $date_received,
            $map_url
            )";
            
            $db->query($sql);

    }

}

class Applications{

    //by point
	function query($lat,$lng,$area_size_meters) {
	    $result = area_coordinates($lat, $lng, $area_size_meters);
        $bottom_left_lat = $result[0];
        $bottom_left_lng = $result[1];
        $top_right_lat = $result[2];
        $top_right_lng = $result[3];
        
		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, description, info_url, comment_url, map_url, lat, lng, date_recieved, date_scraped, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					where application.lat > " . $db->quote($bottom_left_lat) . " and application.lat < " . $db->quote($top_right_lat) .
						" and application.lng > " . $db->quote($bottom_left_lng) . " and application.lng < " . $db->quote($top_right_lng) .
					" order by date_scraped desc limit 100";
		$application_results = $db->getAll($sql);			
		return applications::load_applications($application_results);
	}
	
	//by area
	function query_area($lat1,$lng1,$lat2,$lng2) {

		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, description, info_url, comment_url, map_url, lat, lng, date_recieved, date_scraped, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					where application.lat > " . $db->quote($lat1) . " and application.lat < " . $db->quote($lat2) .
						" and application.lng > " . $db->quote($lng1) . " and application.lng < " . $db->quote($lng2) .
					" order by date_scraped desc limit 100";

		$application_results = $db->getAll($sql);			
		return applications::load_applications($application_results);
	}
	
	//by authority
	function query_authority($authority_short_name) {
		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, description, info_url, comment_url, map_url, lat, lng, date_recieved, date_scraped, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					where authority.short_name = " . $db->quote($authority_short_name) ." order by date_scraped desc limit 100";

			$application_results = $db->getAll($sql);			
			return applications::load_applications($application_results);
	}
	
	//latest
	function query_latest($count = 100) {
		$db = DB::connect(DB_CONNECTION_STRING);
		$sql = "select council_reference, address, description, info_url, comment_url, map_url, lat, lng, date_recieved, date_scraped, full_name
					from application 
					inner join authority on application.authority_id = authority.authority_id
					order by date_scraped desc limit " . $count;

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
				$application->description = $application_results[$i][2];
				$application->info_url = $application_results[$i][3];
				$application->comment_url = $application_results[$i][4];
				$application->map_url = $application_results[$i][5];
				$application->lat = $application_results[$i][6];
				$application->lng  = $application_results[$i][7];
				$application->date_received = $application_results[$i][8];
				$application->date_scraped = $application_results[$i][9];				
				$application->authority_name  = $application_results[$i][10];

				array_push($applications, $application);
			}
		}
		
		return $applications;
	}
}

?>
