<?php

    require_once ("config.php"); 
    require_once ("DB.php");     
    
    class user{
     
     //Properties
    var $user_id = 0;
    var $email ="";    
    var $address ="";            
    var $lat;
    var $lng;
    var $last_sent;
    var $confirm_id;    
    var $confirmed;
    var $area_size_meters;    
    
    
    function save($send_confirmation_email = false){   

        $db = DB::connect(DB_CONNECTION_STRING);

        //Check if it exists, the do an update or insert
        $exists = false;
        if ($this->user_id !=0){
            $sql = "select user_id from user where user_id = " . $this->user_id ;
            $results = $db->query($sql);
            if (sizeof($results) != 0){
                $exists = true;
            }
        }
        
        if (!$exists){
            $this->add();
        }else{
            $this->update();
        }
         
         //Send email
         if($send_confirmation_email == true){
             
             $smarty = new Smarty;
             $smarty->force_compile = true;
             $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
             
             $smarty->assign("email", $this->email);
             $smarty->assign("address", $this->address);  
             $smarty->assign("url", BASE_URL . "/confirmed.php?cid=" . $this->confirm_id);  
             
             //Get the email text
             $email_text = $smarty->fetch('confirm_email_text.tpl');
             
             //Send the email
             send_text_email($this->email, EMAIL_FROM_NAME, EMAIL_FROM_ADDRESS, "Please confirm your planning alert",  $email_text);
                      
         }

     }
     
     function update(){
        $db = DB::connect(DB_CONNECTION_STRING);
        
          $sql = "

             update user
                 set email = " . $db->quote($this->email) . ",
                 address = " . $db->quote($this->address) . ",
                 lat = " . $db->quote($this->lat) . ",
                 lng = " . $db->quote($this->lng) . ",
                 last_sent = " . $db->quote($this->last_sent) . ",
                 confirm_id = " . $db->quote($this->confirm_id) . ",                                                         
                 confirmed = " . $db->quote($this->confirmed) . ",
                 area_size_meters = " . $db->quote($this->area_size_meters) . "
                 where user_id = " .  $db->quote($this->user_id) . "

          ";

          $db->query($sql);
     }
     
     function add(){
          $db = DB::connect(DB_CONNECTION_STRING);

          $sql = "

             insert into user
                 (
                     email,
                     address,
                     lat,
                     lng,
                     last_sent,
                     confirm_id,
                     confirmed,
                     area_size_meters
                 )
                 values(
                     " . $db->quote($this->email) . ",
                     " . $db->quote($this->address) . ",
                     " . $db->quote($this->lat) . ",
                     " . $db->quote($this->lng) . ",
                     " . $db->quote($this->last_sent) . ",
                     " . $db->quote($this->confirm_id) . ",                                                         
                     " . $db->quote($this->confirmed) . ",
                     " . $db->quote($this->area_size_meters) . "
                 )

          ";
          $db->query($sql);
          
     }
     
     //Remove any other alerts for this email/postcode
     function remove_existing(){
          $db = DB::connect(DB_CONNECTION_STRING);
          
          // TODO: Doing a comparison on doubles - highly dodgy!
          // TODO: Should really check within a certain area of the previous alerts
          $sql = "delete from user 
                    where lat = " . $db->quote($this->lat) . "
                        and lng = " . $db->quote($this->lng) ."
                        and email = " . $db->quote($this->email) ."
                        and user_id <> " . $db->quote($this->user_id);
          $db->query($sql);                        
     }
     
     function delete(){
          $db = DB::connect(DB_CONNECTION_STRING);
          $sql = "delete from user where user_id = " . $this->user_id;
          $db->query($sql);                                           
     }
     
     
     function populate_new($email, $address, $alert_area_size){
            
            //Set email, postcode and size
            $this->email = $email;
            $this->address = $address;
            $this->area_size_meters = alert_size_to_meters($alert_area_size);
            
            //Get xy of the postcode
            $result = address_to_lat_lng($address);
            
            $lat = $result[0];
            $lng = $result[1];
            
            $this->lat = $lat;
            $this->lng = $lng;
            
            //Get actual size of zone
            //$area_size_meters = alert_size_to_meters($this->alert_area_size);
            
            //Work out bounding box + buffer area (assumes OSGB location == meters)
            //$area_buffered_meters = $area_size_meters + (($area_size_meters/100) * ZONE_BUFFER_PERCENTAGE);
            
            //$this->bottom_left_x = $xy[0] - ($area_buffered_meters/2);
            //$this->bottom_left_y = $xy[1] - ($area_buffered_meters/2);            
            //$this->top_right_x = $xy[0] + ($area_buffered_meters/2);
            //$this->top_right_y = $xy[1] + ($area_buffered_meters/2);            
            
            //Make a confirmation ID for them (no unique check, ho hum)
             $this->confirm_id = substr(md5(rand(5,15) . time()), 0, 20);
             $this->confirmed = false;
             
             //Set last sent date to yesterday
             $this->last_sent = mysql_date(time() - (24 * 60 * 60));                             
    }
    
    function load_from_confirm_id($confirm_id){
        
        $success = false;
        $db = DB::connect(DB_CONNECTION_STRING);
        $sql = "select user_id, email, address, lat, lng, last_sent, 
            confirm_id, confirmed, area_size_meters
            from user where confirm_id = " . $db->quote($confirm_id);

        $results = $db->getall($sql);
        
        if(sizeof($results) ==1){
            $success = true;            
            $results = $results[0];
            $this->user_id = $results[0];    
            $this->email = $results[1];    
            $this->address = $results[2];            
            $this->lat = $results[3];            
            $this->lng = $results[4];            
            $this->last_sent = $results[5];
            $this->confirm_id = $results[6];    
            $this->confirmed = $results[7];
            $this->area_size_meters = $results[8];        
        }
        
        return $success;
    }
}

?>