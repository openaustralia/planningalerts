<?php

    require_once ("config.php"); 
    require_once ("DB.php");    

	class stats{
	
		public static function get_stats (){

			//this should really be properly cached at some point.
			$return = false;

		    //is the data already in the session?
			if (isset($_SESSION['stats'])){
				$return = $_SESSION['stats'];
			}else{
				$db = DB::connect(DB_CONNECTION_STRING);
				$alert_count = 0;
				$authority_count = 0;			

				//Count of applications
				$alert_sql = "select value from stats where `key` = 'applications_sent'";
				$results =  $db->getAll($alert_sql);

				if(sizeof($results) >0){
					$alert_count = $results[0][0];
				}

				//Count of authorities
				$authority_sql = "select count(authority_id) from authority";
				$results =  $db->getAll($authority_sql);
				if(sizeof($results) >0){
					$authority_count = $results[0][0];
				}	

				//save to session
				$return =  array('alert_count' => $alert_count, 'authority_count' => $authority_count);
				$_SESSION['stats'] = $return;
			}

			return $return;

	    }
	
	}

?>