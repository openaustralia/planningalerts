<?php

    require_once ("config.php"); 
    require_once ("DB.php");     
    
    class user{
     
     //Properties
    var $user_id = 0;
    var $email ="";    
    var $postcode ="";            
    var $last_sent;
    var $bottom_left_x;
    var $bottom_left_y;                    
    var $top_right_x;
    var $top_right_y;    
    var $confirm_id;    
    var $confirmed;
    var $alert_area_size;    
    
    
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
             $smarty->assign("postcode", $this->postcode);  
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
                 postcode = " . $db->quote($this->postcode) . ",
                 last_sent = " . $db->quote($this->last_sent) . ",
                 bottom_left_x = " . $db->quote($this->bottom_left_x) . ",
                 bottom_left_y = " . $db->quote($this->bottom_left_y) . ",
                 top_right_x = " . $db->quote($this->top_right_x) . ",
                 top_right_y = " . $db->quote($this->top_right_y) . ",                                                                                                                    
                 confirm_id = " . $db->quote($this->confirm_id) . ",                                                         
                 confirmed = " . $db->quote($this->confirmed) . ",
                 alert_area_size = " . $db->quote($this->alert_area_size) . "
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
                     postcode,
                     last_sent,
                     bottom_left_x,
                     bottom_left_y,
                     top_right_x,
                     top_right_y,
                     confirm_id,
                     confirmed,
                     alert_area_size
                 )
                 values(
                     " . $db->quote($this->email) . ",
                     " . $db->quote($this->postcode) . ",
                     " . $db->quote($this->last_sent) . ",
                     " . $db->quote($this->bottom_left_x) . ",
                     " . $db->quote($this->bottom_left_y) . ",
                     " . $db->quote($this->top_right_x) . ",
                     " . $db->quote($this->top_right_y) . ",                                                                                                                    
                     " . $db->quote($this->confirm_id) . ",                                                         
                     " . $db->quote($this->confirmed) . ",
                     " . $db->quote($this->alert_area_size) . "
                 )

          ";
          $db->query($sql);
          
     }
     
     //Remove any other alerts for this email/postcode
     function remove_existing(){
          $db = DB::connect(DB_CONNECTION_STRING);
          
          $sql = "delete from user 
                    where postcode = " . $db->quote($this->postcode) . "
                        and email = " . $db->quote($this->email) ."
                        and user_id <> " . $db->quote($this->user_id);
          $db->query($sql);                        
     }
     
     function delete(){
          $db = DB::connect(DB_CONNECTION_STRING);
          $sql = "delete from user where user_id = " . $this->user_id;
          $db->query($sql);                                           
     }
     
     
     function populate_new($email, $postcode, $alert_area_size){
            
            //Set email, postcode and size
            $this->email = $email;
            $this->postcode = $postcode;
            $this->alert_area_size = $alert_area_size;
            
            //cleanup postcode
            $this->postcode = str_replace(" ","", $this->postcode);
            $this->postcode = strtolower($this->postcode);
            
            //Get xy of the postcode
            $xy = postcode_to_location($postcode);
            
            //if we couldent find the XY, throw an exception
            if($xy == false){
                //throw new exception("Something bad happened when trying to convert postcode to X 'n Y");
            }
            
            //Get actual size of zone
            $area_size_meters = alert_size_to_meters($this->alert_area_size);
            
            //Work out bounding box + buffer area (assumes OSGB location == meters)
            $area_buffered_meters = $area_size_meters + (($area_size_meters/100) * ZONE_BUFFER_PERCENTAGE);
            
            $this->bottom_left_x = $xy[0] - ($area_buffered_meters/2);
            $this->bottom_left_y = $xy[1] - ($area_buffered_meters/2);            
            $this->top_right_x = $xy[0] + ($area_buffered_meters/2);
            $this->top_right_y = $xy[1] + ($area_buffered_meters/2);            
            
            //Make a confirmation ID for them (no unique check, ho hum)
             $this->confirm_id = substr(md5(rand(5,15) . time()), 0, 20);
             $this->confirmed = false;
             
             //Set last sent date to yesterday
             $this->last_sent = mysql_date(time() - (24 * 60 * 60));                             
    }
    
    function load_from_confirm_id($confirm_id){
        
        $success = false;
        $db = DB::connect(DB_CONNECTION_STRING);
        $sql = "select user_id, email, postcode, last_sent, 
            bottom_left_x, bottom_left_y, top_right_x, top_right_y,
            confirm_id, confirmed, alert_area_size
            from user where confirm_id = " . $db->quote($confirm_id);

        $results = $db->getall($sql);
        
        if(sizeof($results) ==1){
            $success = true;            
            $results = $results[0];
            $this->user_id = $results[0];    
            $this->email = $results[1];    
            $this->postcode = $results[2];            
            $this->last_sent = $results[3];
            $this->bottom_left_x = $results[4];
            $this->bottom_left_y = $results[5];                    
            $this->top_right_x = $results[6];
            $this->top_right_y = $results[7];    
            $this->confirm_id = $results[8];    
            $this->confirmed = $results[9];
            $this->alert_area_size = $results[10];        
        }
        
        return $success;
    }
}

?>