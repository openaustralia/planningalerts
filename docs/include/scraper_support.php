<?php
	
//Includes
require_once('config.php');
require_once('application.php');
require_once ("PEAR/HTTP/Request.php");     
require_once('phpcoord.php');

//Generic scrapers
function scrape_applications_publicaccess ($search_url, $info_url_base, $comment_url_base){

	$applications = array();
	//$application_pattern = "/<tr><th>([0-9]*)<\/th>([^;]*)([^<]*)/";
	$application_pattern = "/<tr><th>([0-9]*)<\/th>.*(?=<\/tr)/U";

    //grab the page
    $html = safe_scrape_page($search_url);

	//clean html
	$html = str_replace("\r\n","", $html);

	preg_match_all($application_pattern, $html, $application_matches, PREG_PATTERN_ORDER);

	foreach ($application_matches[0] as $application_match){
		//START Duncan's debug
		//print_r($application_match);
		//print_r("END");
		// END Duncan's debug

		$detail_pattern = "/<td>([^<])*/";
		preg_match_all($detail_pattern, $application_match, $detail_matches, PREG_PATTERN_ORDER);

		$application = new Application();

		//match the basic details
		$application->council_reference = str_replace("<td>", "", $detail_matches[0][0]);
		$application->date_received = str_replace("<td>", "", $detail_matches[0][1]);			
		$application->address = str_replace("<td>", "", $detail_matches[0][2]);
		//$application->status = str_replace("<td>", "", $detail_matches[0][4]);
		     
        //match case number
		$casenumber_pattern = "/caseno=([^&]*)/";
		preg_match($casenumber_pattern, $application_match, $casenumber_matches);
		//START Duncan's debug
		//print_r($application_match);
		//var_dump($casenumber_matches);
		//END Duncan's debug

		$case_number ="";
		if(sizeof($casenumber_matches)>0){
		    $case_number = str_replace("caseno=","", $casenumber_matches[0]);
	    }

		//if weve found a caase number, then get the details
		if($case_number !=""){
    		//Comment and info urls		    
    		$application->info_url = $info_url_base . $case_number;
    		$application->comment_url = $comment_url_base . $case_number;		

    		//Get the postcode
    		$postcode_pattern = "/[A-Z][A-Z]?[0-9][A-Z0-9]? ?[0-9][ABDEFGHJLNPQRSTUWXYZ]{2}/";

    		preg_match($postcode_pattern, $application->address, $postcode_matches);
    		if(isset($postcode_matches[0])){
    		    $application->postcode = $postcode_matches[0];
    	    }

    		//get full details
    		$details_html = "";
    		$details_html = safe_scrape_page($info_url_base . $case_number);

    		//regular expresion and clean
    		$full_detail_pattern = '/id="desc" rows="[1-9]" cols="80" class="cDetailInput">([^<]*)/';
    		preg_match($full_detail_pattern, $details_html, $full_detail_matches);
    		if (isset($full_detail_matches[0])){
    		$application->description =  substr($full_detail_matches[0], strpos($full_detail_matches[0], ">") + 1);
		}

            //only add it if we have a postcode (bit useless otherwise)
            if(is_postcode($application->postcode)){
    		    array_push($applications, $application);
    	    }
    	}else{
    	    error_log("Unable to find case number for an application at " . $search_url);
	    }
	}

	//return
	return $applications;
}

function scrape_applications_wam ($search_url, $info_url_base, $comment_url_base, $detail_mode = 1){

	$applications = array();
	$application_pattern = '/<tr><td class=[^>]*>([^<]*)<\/td><td class=[^>]*><a href="[^"]*">([^<]*)<\/a><\/td><td class=[^>]*>([^<]*)<\/td><td class=[^>]*>([^<]*)<\/td>/';


    //grab the page
    $html = safe_scrape_page($search_url);

	//clean html
	$html = str_replace("\r\n","", $html);

	preg_match_all($application_pattern, $html, $application_matches, PREG_SET_ORDER);

	foreach ($application_matches as $application_match){
		if ($application_match[4] != 'Current') { continue; }

		$application = new Application();

		//match the basic details
		$application->council_reference = $application_match[2];
		$case_number = $application_match[2];
		$application->date_received = $application_match[1];			
		$application->address = $application_match[3];
		//$application->status = $application_match[4];

		//if weve found a caase number, then get the details
		if($case_number !=""){
    		//Comment and info urls		    
    		$application->info_url = $info_url_base . $case_number;
    		$application->comment_url = $comment_url_base . $case_number;		

    		//Get the postcode
    		$postcode_pattern = "/[A-Z][A-Z]?[0-9][A-Z0-9]? ?[0-9][ABDEFGHJLNPQRSTUWXYZ]{2}/";

    		preg_match($postcode_pattern, $application->address, $postcode_matches);
    		if(isset($postcode_matches[0])){
    		    $application->postcode = $postcode_matches[0];
    	    }

    		//get full details
    		$details_html = "";
    		$details_html = safe_scrape_page($info_url_base . $case_number);
			$details_html = str_replace("\r\n","",$details_html);

    		//regular expresion and clean. SItes vary a tiny bit in their html, so there's a bit of a hack here
    		if ($detail_mode == 1){
    		    $full_detail_pattern = '/Development:<.*<td colspan="3">([^<]*)<\/td>/';
		    }
		    if ($detail_mode == 2){
                $full_detail_pattern = '/Development:<\/td><td>([^<]*)/';
		    }

    		preg_match($full_detail_pattern, $details_html, $full_detail_matches);

    		if (isset($full_detail_matches[1])){
    			$application->description =  $full_detail_matches[1];
			}

            //only add it if we have a postcode (bit useless otherwise)
            if(is_postcode($application->postcode)){
                
                //removed the xy for the moment. It is slowing down the scrape and will be added when the app is parsed anyway (Richard)
/*				$xy = postcode_to_location($application->postcode);
				$application->x = $xy[0];
				$application->y = $xy[1];
				$os = new OSRef($xy[0],$xy[1]);
				$latlon = $os->toLatLng();
				$application->lat = $latlon->lat;
				$application->lon = $latlon->lng;
*/
    		    array_push($applications, $application);
    	    }
    	}else{
    	    error_log("Unable to find case number for an application at " . $search_url);
	    }

	}

	//return
	return $applications;
}

// Council specific scapers
function scrape_applications_islington ($search_url, $info_url_base, $comment_url_base){

	$applications = array();
	$application_pattern = '/<TR>([^<]*)<TD class="lg" valign="top" >([^<]*)<a href([^<]*)<a href=wphappcriteria.display>Search Criteria(.*)([^<]*)<(.*)>([^<]*)<TD class="lg" >([^<]*)<\/TD>([^<]*)<TD class="lg" >([^<]*)<INPUT TYPE=HIDDEN NAME([^>]*)([^<]*)/';

    //grab the page
    $html = safe_scrape_page($search_url);

	preg_match_all($application_pattern, $html, $application_matches, PREG_PATTERN_ORDER);

	foreach ($application_matches[0] as $application_match){
	    
	    $application_string = str_replace("\n","", $application_match);
	            
		$reference_pattern = '/Search Results<\/a>">([^<]*)/';
		preg_match_all($reference_pattern, $application_string, $reference_matches, PREG_PATTERN_ORDER);

		$application = new Application();

		//match the applicaiton number
		$application->council_reference = str_replace('Search Results</a>">', "", $reference_matches[0][0]);

		//Comment and info urls		    
		$application->info_url = $info_url_base . $application->council_reference;
		$application->comment_url = $comment_url_base . $application->council_reference;			

		//get full details
		$details_html = "";
		$details_html = safe_scrape_page($info_url_base . $application->council_reference);
		$details_html = str_replace("\r\n","",$details_html);		

        //Details
        $full_detail_pattern = '/Proposal:<\/label><\/td>([^<]*)<td colspan="3">([^<]*)/';
                
		preg_match($full_detail_pattern, $details_html, $full_detail_matches);
		if (isset($full_detail_matches[2])){
			$application->description =  $full_detail_matches[2];			
		}

        //Address
        $address_pattern = '/Main location:<\/label><\/td>([^<]*)<td colspan="3">([^<]*)/';
        $address = "";
    	preg_match($address_pattern, $details_html, $address_matches);
		if(isset($address_matches[2])){
		    $application->address = $address_matches[2];
        }
        
		//postcode
		$postcode_pattern = "/[A-Z][A-Z]?[0-9][A-Z0-9]? ?[0-9][ABDEFGHJLNPQRSTUWXYZ]{2}/";
		preg_match($postcode_pattern, $application->address, $postcode_matches);
		if(isset($postcode_matches[0])){
		    $application->postcode = $postcode_matches[0];
	    }

        //only add it if we have a postcode (bit useless otherwise)
        if(is_postcode($application->postcode)){
		    array_push($applications, $application);
	    }
	}

	//return
	return $applications;
}    
    //validate postcode
    function is_postcode ($postcode){
       $valid = false;
       $postcode=str_replace(" ","",$postcode);
       if(ereg ('^[a-zA-Z]{1,2}[0-9]{1,2}[a-zA-Z]{0,1}[0-9]{1}[a-zA-Z]{2}$', $postcode)){
          $valid = true;
       }
       return $valid;
    }

	function clean_postcode ($postcode, $upper = true) {

		$reg = array();
		$postcode = trim($postcode);
		preg_match('/^(.+?)([0-9][a-z]{2})$/',$postcode, $reg);
	
		$clean_postcode = trim($reg[1]) . ' ' . trim($reg[2]);
	
		if($upper){
			$clean_postcode = strtoupper($clean_postcode);
		}
	
		return $clean_postcode;
	
	}
    
    //Tiny url
    function tiny_url($url,$length=30){

    	// make nasty big url all small
    	if (strlen($url) >= $length){
    		$tinyurl = @file ("http://tinyurl.com/api-create.php?url=$url");
    		
    		if (is_array($tinyurl)){
    			$tinyurl = join ('', $tinyurl);
    		} else {
    			$tinyurl = $url;
    		}
    	} else {  
    		$tinyurl = $url; 
    	}

    	return $tinyurl;
    }
    
    //Google maps url
    function googlemap_url_from_postcode($postcode, $zoom = 15){
        $postcode = strtolower(str_replace(" ", "+", $postcode));
        return "http://maps.google.co.uk/maps?q=$postcode&z=$zoom";
    }
    

    //postcode to location
    function postcode_to_location($postcode){

	// We don't actually need to fetch the page, we
	// can get everything we need from the url we are
	// redirected to.
        $clean_postcode = strtolower($postcode);
        $clean_postcode = str_replace(" ","+", $clean_postcode);

        $url = "http://ernestmarples.com/?p=sw98jx&f=csv";
        $result = file_get_contents($url);
        $result = split(",", $result);
        if(count($result) != 2){
            trigger_error("No lat/long could be found");
        }
        $lat = $result[0];
        $lng = $result[1];

        $LatLng = new LatLng($lat, $lng);
        $OSBG = $LatLng->toOSRef();

        $return = array($OSBG->easting, $OSBG->northing);

    }
        
    function location_to_postcode($easting, $northing) {
        $url = sprintf(
            "http://streetmap.co.uk/streetmap.dll?GridConvert?name=%d,%d&type=OSGrid",
            $easting, $northing);
        $resp = @file($url);
        if (is_array($resp)) $resp = join("\n", $resp);
        $resp = strip_tags($resp);
        // Kinda ghetto. Would be nice to have a nicer regex for postcodes.
        if (preg_match('/Nearest\s+Post\s+Code\s+(\S+\s+\S+)/i', $resp, $mat))
            return $mat[1];
        return NULL;
    }
    
    function valid_email ($string) {
        $valid = false;
    	if (!ereg('^[-!#$%&\'*+\\./0-9=?A-Z^_`a-z{|}~]+'.
    		'@'.
    		'[-!#$%&\'*+\\/0-9=?A-Z^_`a-z{|}~]+\.'.
    		'[-!#$%&\'*+\\./0-9=?A-Z^_`a-z{|}~]+$', $string)) {
    		$valid = false;
    	} else {
    		$valid =  true;
    	}
    	
    	return $valid;
    }
    
    function alert_size_to_meters($alert_area_size){
        
        $area_size_meters = 0;
        if ($alert_area_size == "s"){
            $area_size_meters = SMALL_ZONE_SIZE;
        }elseif ($alert_area_size == "m"){
            $area_size_meters = MEDIUM_ZONE_SIZE;                
        }elseif ($alert_area_size == "l"){
            $area_size_meters = LARGE_ZONE_SIZE;                
        }   
        return $area_size_meters;
    }
    
    //Send a text email
    function send_text_email($to, $from_name, $from_email, $subject, $body){
        
    	$headers  = 'MIME-Version: 1.0' . "\r\n";
		$headers .= 'Content-type: text/plain; charset=iso-8859-1' . "\r\n";
		$headers .= 'From: ' . $from_name. ' <' . $from_email . ">\r\n";
		    
		mail($to, $subject, $body, $headers);

    }
    
    // Format a date to mysql format
    function mysql_date($date){
        return date("Y-m-d H::i:s", $date);
    }
    
    function safe_scrape_page($url, $method = "GET"){

        $page = "";
        for ($i=0; $i < 3; $i++){ 
            if($page == false){
                 if (SCRAPE_METHOD == "PEAR"){
                     $page = scrape_page_pear($url, $method);
                 }else{
                     $page = scrape_page_curl($url, $method);         
                 }
            }   
        }
        return $page;
    }
    
    function scrape_page_pear($url, $method = "GET"){
        $page = "";
        $request = new HTTP_Request($url, array("method" => $method));
        $request->sendRequest();
        $page = $request->getResponseBody();
        
        return $page;

    }
    
    function scrape_page_curl($url) {
		$ch = curl_init($url);
		curl_setopt($ch,CURLOPT_RETURNTRANSFER,TRUE);
		curl_setopt($ch,CURLOPT_FOLLOWLOCATION,TRUE);
		return curl_exec($ch);
	}
    
    function display_applications($applications, $authority_name, $authority_short_name){
        //smarty
    	$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
        $smarty->template_dir = "../templates";
        $smarty->assign("authority_name", $authority_name);
        $smarty->assign("authority_short_name", $authority_short_name);    

    	if (sizeof($applications) > 0){
            $smarty->assign("applications", $applications);
    	}

    	$smarty->display("xml.tpl");
    }
    
function get_time_from_get(){
        
        //if any get params were passed, overwrite the default date
        if (isset($_GET['day'])){
            $day = $_GET['day'];
        }else{
            throw_error("No day set in get string");
        }
        if (isset($_GET['month'])){
            $month = $_GET['month'];
        }else{
            throw_error("No year set in get string");
        }

        if (isset($_GET['year'])){
            $year = $_GET['year'];
        }else{
            throw_error("No year set in get string");
        }

        return mktime(0,0,0,$month,$day,$year);

    }
    
function throw_error($message){
    throw new exception($message);
}

function redirect ($url){
    header("Location: $url");
}

?>
