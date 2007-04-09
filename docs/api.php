<?php 
    require_once ("config.php"); 
    require_once ("phpcoord.php");    
            
$api = new api;

class api {

    //Properties
	var $warnings = array();
	var $applications;

	//Constructor
	function api() {
		if (isset($_GET['howto'])){
			redirect("apihowto.php");//this handles old links to this page
			exit;
		} else {
		    if(isset($_GET['call'])){
			    $this->setup();
			}else{
			    $this->setup_old();
			}
			$this->bind();
		}
	}
	
	//setup
	function setup(){

        //get the call type
        $call = $_GET['call'];
        
        switch ($call) {
            case "postcode":        

                    if(!isset($_GET['area_size']) || !is_postcode($_GET['postcode'])){
                        array_push($this->warnings, "No valid postcode specified");
                    }
                    if(!isset($_GET['area_size'])){
                        array_push($this->warnings, "Area size specified");
                    }

                    //all good, get the data
                    if(sizeof($this->warnings) == 0){

                        $xy = postcode_to_location($_GET['postcode']);
            			$easting = $xy[0];
            			$northing = $xy[1];
            			$this->applications = Applications::query($easting, $northing, alert_size_to_meters($_GET['area_size']));
                    }
                    
                break;
            case "point":
                //validation
                if(!isset($_GET['lat']) || !isset($_GET['lng'])){
                    array_push($this->warnings, "No longitude or latitude was specified");
                }
                if(!isset($_GET['area_size'])){
                    array_push($this->warnings, "Area size specified");
                }
                //all good, get the data
                if(sizeof($this->warnings) == 0){
    				$latlng = new LatLng($_GET['lat'], $_GET['lng']);
    				$xy = $latlng->toOSRef();
        			$easting = $xy->easting;
        			$northing = $xy->northing;
        			$this->applications = Applications::query($easting, $northing, alert_size_to_meters($_GET['area_size']));
                }
                break;
                case "pointos":
                    //validation
                    if(!isset($_GET['easting']) || !isset($_GET['northing'])){
                        array_push($this->warnings, "No easting or northing was specified");
                    }
                    if(!isset($_GET['area_size'])){
                        array_push($this->warnings, "Area size specified");
                    }
                    //all good, get the data
                    if(sizeof($this->warnings) == 0){
            			$this->applications = Applications::query($_GET['easting'], $_GET['$northing'], alert_size_to_meters($_GET['area_size']));
                    }
                    break;    
                case "authority":
                    //validation
                    if(!isset($_GET['authority'])){
                        array_push($this->warnings, "No authority name specified");
                    }

                    //all good, get the data
                    if(sizeof($this->warnings) == 0){
            			$this->applications = Applications::query_authority($_GET['authority']);
                    }
                    break;           
                case "area":
                    //validation
                    if(!isset($_GET['bottom_left_lat']) || !isset($_GET['bottom_left_lng']) || !isset($_GET['top_right_lat']) || !isset($_GET['top_right_lng'])){
                        array_push($this->warnings, "Bounding box was not specified");
                    }

                    //all good, get the data
                    if(sizeof($this->warnings) == 0){
        				$bottom_left_latlng = new LatLng($_GET['bottom_left_lat'], $_GET['bottom_left_lng']);
        				$bottom_left_xy = $latlng->toOSRef();
        				$top_right_latlng = new LatLng($_GET['bottom_left_lat'], $_GET['bottom_left_lng']);
        				$top_right_xy = $latlng->toOSRef();

            			$this->applications = Applications::query_area($bottom_left_xy->easting, $bottom_left_xy->northing, $top_right_xy->easting, $top_right_xy->northing);
                    }
                break;
            default:
                $this->warnings = "No call type specified";
        }
    
    }
    
	
    //setup old (maintains the original mini api)
    function setup_old (){
        //Grab the postcode and area size from the get string
        if (!isset($_GET['area_size'])){ //check is_numeric and isn't too big
            array_push($this->warnings, "No area size specified");
        }

        if (sizeof($this->warnings) == 0){     
            //Get OS ref from postcode
			if (isset($_GET['postcode'])) {
            	$xy = postcode_to_location($_GET['postcode']);
    			$this->easting = $xy[0];
    			$this->northing = $xy[1];        	
			} else {
				$latlng = new LatLng($_GET['lat'], $_GET['lng']);
				$xy = $latlng->toOSRef();
    			$this->easting = $xy->easting;
    			$this->northing = $xy->northing;				
			}	

			$this->area_size = $_GET['area_size'];

			$this->applications = Applications::query($this->easting, $this->northing, alert_size_to_meters($this->area_size));
        }

    }

	//Bind
	function bind () {
	    
		//page vars
		$form_action = $_SERVER['PHP_SELF'];

		header("Content-Type: text/xml");

		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
        
		$smarty->assign("warnings", $this->warnings);
		$smarty->assign("applications", $this->applications);
	
		//Render
		$smarty->display('rss.tpl');
		
	}

	//howto
	function howto() {
		$form_action = $_SERVER['PHP_SELF'];

		$smarty = new Smarty;
		$smarty->force_compile = true;
		$smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;

		$smarty->assign("page_title","API");
		$smarty->assign("menu_item","api");

		$smarty->display('apihowto.tpl');
	}

}



?>
