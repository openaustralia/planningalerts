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

    //Run
     function run (){
         
        $db = DB::connect(DB_CONNECTION_STRING);
                 
         //Grab all the users
         $sql = "select user_id, email, postcode, bottom_left_x, bottom_left_y, top_right_x, top_right_y, alert_area_size, confirm_id
            from user
            where confirmed = 1 and last_sent < " . $db->quote(mysql_date(time() - (20 * 60 * 60)));  

        $this->store_log("Grabbing users");
             
         $user_results = $db->getAll($sql);
         
         $this->store_log("Found " . sizeof($user_results) . " who havnt been checked since " . mysql_date(time() - (20 * 60 * 60)));
                      
         if(sizeof($user_results) > 0){
             
             //Loop though users
             for ($i=0; $i < sizeof($user_results); $i++){ 

                 $this->store_log("Processing user " . $i);
                
                 //Find applications for that user
                 $sql = "select council_reference, address, 
                            postcode, description, info_tinyurl, 
                            comment_tinyurl, map_url, full_name
                        from application
                            inner join authority on application.authority_id = authority.authority_id 
                         where date_scraped > " . $db->quote(mysql_date(time() - (24 * 60 * 60))) . 
                            " and (application.x > " .  $user_results[$i][3] . " and application.x < " . $user_results[$i][5] . ")
                              and (application.y > " .  $user_results[$i][4] . " and application.y < " . $user_results[$i][6] . ")";

                $application_results = $db->getAll($sql);

                //Send email if we have any 
                if(sizeof($application_results) > 0){

                    $this->store_log("Found " . sizeof($application_results) . "applications for this user. w00t!");
                    
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
                    
                    //Smarty template
                    $smarty = new Smarty;
                    $smarty->force_compile = true;
                    $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
                    $smarty->assign("applications", $applications);
                    $smarty->assign("base_url", BASE_URL);
                    $smarty->assign("confirm_id", $user_results[$i][8]);      
                    
                    //Get the email text
                    $email_text = $smarty->fetch(SMARTY_TEMPLATE_DIRECTORY . 'alert_email_text.tpl');
                    
                    //Send the email
                    if($email_text !=""){
                        send_text_email($user_results[$i][1], EMAIL_FROM_NAME, EMAIL_FROM_ADDRESS, "Planning applications near " . $user_results[$i][2],  $email_text);
                        $this->store_log("sent applications to " . $user_results[$i][1]);
                    }else{
                        $this->store_log("BLANK EMAIL TEXT !!! EMAIL NOT SENT");
                    }
                 
                    //Update last sent
                    $sql = "update user set last_sent = " . $db->quote(mysql_date(time())) . " where user_id = " . $user_results[$i][0];
                    $db->query($sql);   
                    $this->store_log("Updating last checked date/time");
                }

             }

         }
      
      //Send the log
      send_text_email(LOG_EMAIL, "mailer@" . DOMAIN, "mailer@" . DOMAIN, "Planning mailer log", print_r($this->log, true));
      
      $this->store_log("Debug email sent to " . LOG_EMAIL);
         
     }
     
     function store_log($text){
            array_push($this->log, $text);
            print $text . "\n\n";
     }  
        
    }

?>