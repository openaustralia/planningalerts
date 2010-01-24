<?php

    require_once('tools_ini.php'); 
    require_once('application.php'); 
    require_once('DB.php');

    //initialise
    $application_mailer = new application_mailer();
    $application_mailer->run();

    //class
    class application_mailer {
        
    //Properties
    var $log = array();
	var $application_count = 0;
	var $email_count = 0;

    //Run
     function run (){

        $db = DB::connect(DB_CONNECTION_STRING);
                 
         //Grab all the users
         $sql = "select user_id, email, address, lat, lng, area_size_meters, confirm_id
            from user
            where confirmed = 1 and last_sent < " . $db->quote(mysql_date(time() - (20 * 60 * 60)));  

        $this->store_log("Grabbing users");
             
         $user_results = $db->getAll($sql);
         
         $this->store_log("Found " . sizeof($user_results) . " who havnt been checked since " . mysql_date(time() - (20 * 60 * 60)));
                      
         if(sizeof($user_results) > 0){
             
             //Loop though users
             for ($i=0; $i < sizeof($user_results); $i++){
                 $user_id = $user_results[$i][0];
                 $email = $user_results[$i][1];
                 // TODO: Hmm.. Alert address is actually much more descriptive than address. Maybe change this in the schema?
                 $alert_address = $user_results[$i][2];
                 $lat = $user_results[$i][3];
                 $lng = $user_results[$i][4];
                 $area_size_meters = $user_results[$i][5];
                 $confirm_id = $user_results[$i][6];
                 
                 // Calculate bounds of search area for this user
                 $result = area_coordinates($lat, $lng, $area_size_meters);
                 $bottom_left_lat = $result[0];
                 $bottom_left_lng = $result[1];
                 $top_right_lat = $result[2];
                 $top_right_lng = $result[3];
                 
                 //Find applications for that user
                 $sql = "select distinct council_reference, address, 
                            postcode, description, info_tinyurl, 
                            comment_tinyurl, map_url, full_name
                        from application
                            inner join authority on application.authority_id = authority.authority_id 
                         where date_scraped > " . $db->quote(mysql_date(time() - (24 * 60 * 60))) . 
                            " and (application.lat > " .  $bottom_left_lat . " and application.lat < " . $top_right_lat . ")
                              and (application.lng > " .  $bottom_left_lng . " and application.lng < " . $top_right_lng . ") and (application.lat <> 0  and application.lng <> 0 )";

                $application_results = $db->getAll($sql);

                //Send email if we have any 
                if(sizeof($application_results) > 0){
                    
                    //Setup applications array (bit pikey this)
                    $applications = array();
                    for ($ii=0; $ii < sizeof($application_results); $ii++){ 
       
                        $application = new application();
                        $application->council_reference = $application_results[$ii][0];
                        $application->address = $application_results[$ii][1]; 
                        $application->postcode = $application_results[$ii][2];
                        $application->description= $application_results[$ii][3];
                        $application->info_tinyurl= $application_results[$ii][4];
                        $application->comment_tinyurl= $application_results[$ii][5];
                        $application->map_url = $application_results[$ii][6];
                        $application->authority_name = $application_results[$ii][7];                        
                        
                        array_push($applications, $application);
                    }

					$this->application_count += sizeof($applications); 
                    
                    //Smarty template
                    $smarty = new Smarty;
                    $smarty->force_compile = true;
                    $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
                    $smarty->assign("applications", $applications);
                    $smarty->assign("base_url", BASE_URL);
                    $smarty->assign("confirm_id", $confirm_id);      
                    $smarty->assign("area_size_meters", $area_size_meters);                          
                    $smarty->assign("alert_address", $alert_address);
                    $smarty->assign("georss_url", BASE_URL . "/api.php?call=address&address=" . urlencode($alert_address) . "&area_size=" . $area_size_meters);
                    
                    //Get the email text
                    $email_text = $smarty->fetch(SMARTY_TEMPLATE_DIRECTORY . 'alert_email_text.tpl');
                    
                    //Send the email
                    if($email_text !=""){
                        send_text_email($email, EMAIL_FROM_NAME, EMAIL_FROM_ADDRESS, "Planning applications near " . $alert_address,  $email_text);
						$this->email_count +=1;
                    }else{
                        $this->store_log("BLANK EMAIL TEXT !!! EMAIL NOT SENT");
                    }

                    //Update last sent
                    $sql = "update user set last_sent = " . $db->quote(mysql_date(time())) . " where user_id = " . $user_id;
                    $db->query($sql);   
                    $this->store_log("Updating last checked date/time");
                }

             }

         }

      $this->store_log("Sent " . $this->application_count . " applications  to " . $this->email_count . " people!");	

	 //update the number of apps sent
	  $sql = "select `key`, `value` from stats";
	  $stats_results = $db->getAll($sql);
	  $new_application_total = 0;	
	  $new_email_total = 0;	
	  for ($i=0; $i < sizeof($stats_results); $i++){ 
			if($stats_results[$i][0] == 'applications_sent'){
				$new_application_total = $stats_results[$i][1] + $this->application_count;
			}
			elseif ($stats_results[$i][0] == 'emails_sent'){
				$new_email_total = $stats_results[$i][1] + $this->email_count;
			}	
	  }
	
	//add stats to email
	 $this->store_log("Total applications ever sent:  " . $new_application_total);	
	 $this->store_log("Total emails ever sent:  " . $new_email_total);
	
	//update stats in DB
	 $sql = "update stats set `value` = " . $new_application_total . " where `key` = 'applications_sent'";
	 $db->query($sql);	
	
	 $sql = "update stats set `value` = " . $new_email_total . " where `key` = 'emails_sent'";
	 $db->query($sql);
		
      //Send the log
      send_text_email(LOG_EMAIL, "mailer@" . DOMAIN, "mailer@" . DOMAIN, "Planning mailer log", print_r($this->log, true));
         
     }
     
     function store_log($text){
            array_push($this->log, $text);
            print $text . "\n\n";
     }  
        
    }

?>