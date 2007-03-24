<?php 
    require_once ("config.php"); 
    require_once ("phpcoord.php");    
            
$api = new api;

class api {

    //Properties
	var $warnings = "";
	var $easting = 0;
	var $northing = 0;
	var $area_size = 0;
	var $applications;

	//Constructor
	function api() {
		if (isset($_GET['howto'])){
			$this->howto();
		} else {
			$this->setup();
			$this->bind();
		}
	}
	
    //setup
    function setup (){
        
        //Grab the postcode and area size from the get string
        
        if (!isset($_GET['area_size'])){ //check is_numeric and isn't too big
            $this->warnings .= "No area size specified ";
        }
		if (!(isset($_GET['lat']) && isset($_GET['lng'])) 
			|| !(isset($_GET['postcode'])) ) {
			$this->warmings .= "No location specified ";
		}
        
        if ($this->warnings == ""){     
            
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
