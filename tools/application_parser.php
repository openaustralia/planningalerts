<?php

    require_once('tools_ini.php');
    require_once('application.php');
    require_once('DB.php');
    
    $swiches = getopt('d:');

	$day = isset($swiches['d']) ? $swiches['d'] : null;
		
    //Initialise
    $application_parser = new application_parser();

	if(isset($day)){
        $application_parser->date = getdate(strtotime("-" . $day . " days"));
        $application_parser->run();		
	}else{
	    //Scrape for the last X days (apps already in the database are ignored)
	    for ($i=0; $i < SCRAPE_DELAY; $i++){ 
	        $application_parser->date = getdate(strtotime("-" . $i . " days"));
	        $application_parser->run();
	    }
	}

    //Send email
    $application_parser->email_log();

    //Parser class
    class application_parser{

    //Properties
    var $date;
    var $log = array();
    var $sleep_interval = 2; //how long to wait between scraping each feed
     
    //Constructor
   function application_parser (){
     
        //set default date
        $this->date = getdate();
        
    }
     
    //Run
    function run(){
        
        $db = DB::connect(DB_CONNECTION_STRING);
        $sql = "Select authority_id, feed_url, external, disabled, short_name from authority where disabled <> 1";
        $results = $db->getAll($sql);
        
        if (sizeof($results) == 0){
            //throw new exception("You need to put some authorities to scrape in the database");
        }

        //log
        $this->store_log("Scraping " . sizeof($results) . "authorities");

        //Parse & save each feed        
        foreach($results as $result){
            
            //reset the timeout
            set_time_limit(0);    
               
            $authority_id = $result[0];
            $external = $result[2];
            $disabled = $result[3];
            if($external != true){
                $feed_url = BASE_URL . $feed_url = $result[1];
            }else{
                $feed_url = $result[1];
            }
            
            //replace date wild cards
            $feed_url = str_replace("{day}",$this->date['mday'], $feed_url);
            $feed_url = str_replace("{month}",$this->date['mon'], $feed_url);
            $feed_url = str_replace("{year}",$this->date['year'], $feed_url);                        

            //log
            $this->store_log("Scraping authority " . $result[4] . " from " . $feed_url);
            
            //if it isnt disabled parse it
            if ($disabled == false){
                $applications = $this->parse_applications($feed_url, $authority_id);
               
               //log
                $this->store_log("Found " . sizeof($applications) . " applications for " . $result[4]);                 
                
                //save applications (probably shouldent be saved individually, but sod it for the moment)
                foreach ($applications as $application){
                    if(!$application->exists()){
                        $application->save();
                        $this->store_log("Saving application" . $application->council_reference);                        
                    }else{
                        $this->store_log("Application already exists in database" . $application->council_reference);                        
                    }
                }

            }
            
            //wait for a bit so we dont blow anyone's server (mainly tinyurl)
            sleep($this->sleep_interval);
            
        }

    }    
     
    //Turn xml into application objects
    function parse_applications($feed_url, $authority_id){
        
        $return_applications = array();
        
        //reset warnings
        
        //Grab the XML
        $xml = "";
        try{
            $xml = safe_scrape_page($feed_url);
        }catch (exception $e){
            array_push($this->log, "ERROR: problem occured when grabbing feed: " . $feed_url . " ---->>>" . $e);    
        }
        
        if ($xml == false){
            $this->store_log("ERROR: empty feed feed: " . $feed_url);
        }

        //Turn the xml into an object
        $parsed_applications = simplexml_load_string($xml);

        //Loop through the applications, add tinyurl / google maps etc and add to array
        if(sizeof($parsed_applications) >0){
            foreach($parsed_applications->applications->application as $parsed_application){

                $application = new application();

                //Grab basic data from the xml
                $application->authority_id = $authority_id;
                $application->council_reference = $parsed_application->council_reference;

                $date_received_dmy = split("/", $parsed_application->date_received);
                if (count($date_received_dmy) == 3){
                    $application->date_received = "$date_received_dmy[2]-$date_received_dmy[1]-$date_received_dmy[0]";
                } else {
                    // Make a best effort attempt to parse the date
                    $ts = strtotime($parsed_application->date_received);
                    if ($ts != FALSE && $ts != -1) {
                        $application->date_received = date("Y-m-d", $ts);
                    }
                }

                $application->address = $parsed_application->address;            
                $application->description = $parsed_application->description;
                $application->info_url = $parsed_application->info_url;
                $application->comment_url = $parsed_application->comment_url;                        
                $application->date_scraped = mysql_date(time());

                //Make the urls
                $info_tiny_url = tiny_url($application->info_url);
                if ($info_tiny_url == ""){
                    $this->store_log("ERROR: Created blank info tiny url");
                }
                $comment_tiny_url = tiny_url($application->comment_url);            
                if ($comment_tiny_url == ""){
                    $this->store_log("ERROR: Created blank comment tiny url");
                }

                if (isset($parsed_application->postcode)) {
                    //Workout the XY location from postcode
                    $xy = postcode_to_location($parsed_application->postcode);
                    $application->postcode = $parsed_application->postcode;
                    $application->x        = $xy[0];
                    $application->y        = $xy[1];            
                }
                else if (isset($parsed_application->easting) && 
                         isset($parsed_application->northing)) {
                    $postcode = location_to_postcode(
                      $parsed_application->easting, 
                      $parsed_application->northing
                    );
                    $application->postcode = $postcode;
                    $application->x        = $parsed_application->easting;
                    $application->y        = $parsed_application->northing;
                }

                $application->info_tinyurl =$info_tiny_url;            
                $application->comment_tinyurl = $comment_tiny_url;
                $application->map_url = googlemap_url_from_postcode($application->postcode);
            
                //Add to array
                array_push($return_applications, $application);

            }
        }
        return $return_applications;

    }
    
    function store_log($text){
           array_push($this->log, $text);
           print $text . "\n\n";
    }

    function email_log(){
        //Email log
        send_text_email(LOG_EMAIL, "parser@" . DOMAIN, "parser@" . DOMAIN, "Planning parser log", print_r($this->log, true));
        $this->store_log("Debug email sent to " . LOG_EMAIL);
    }   
        
}

?> 
