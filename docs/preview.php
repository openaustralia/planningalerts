<?php 
    require_once ("config.php"); 
    require_once ("phpcoord.php");    
            
$preview_page = new preview_page;

class preview_page {

    //Properties
	var $warnings = "";
	var $center_long = 0;
	var $center_lat = 0;	
	var $bottom_left_long = 0;	
	var $bottom_left_lat = 0;		
	var $top_right_long = 0;	
	var $top_right_lat = 0;	

	//Constructor
	function preview_page() {
		$this->setup();
		$this->bind();
	}
	
    //setup
    function setup (){
        
        //Grab the postcode and area size from the get string
        
        if (!isset($_GET['address'])){
            $this->warnings .= "No street address specified ";
        }
        if (!isset($_GET['area_size'])){
            $this->warnings .= "No area size specified ";
        }

        if ($this->warnings == ""){
            
            //$url = "http://ernestmarples.com/?p=sw98jx&f=csv";
            //$result = file_get_contents($url);
            //$result = split(",", $result);
            //if(count($result) != 2){
            //    trigger_error("No lat/long could be found");
            //}
			// For the time being hack in a fixed location

	        $lat = 51.48762641022281;
	        $lng = -0.10890305042266846;

            //$lat = $result[0];
            //$lng = $result[1];

            //Get OS ref from postcode
            //$xy = postcode_to_location($_GET['postcode']);

            //Get the centroid long  / lat (google maps doesnt handle grid refs)
            //$os_ref = new OSRef($xy[0], $xy[1]);
            //$long_lat = $os_ref->toLatLng();
            $this->center_long = $lng; //$long_lat->lng;
            $this->center_lat = $lat; //$long_lat->lat;            
            
            //get long lat for the bounding box (OS grid refs are in meters in case you were wondering)
            
            //bottom left
            $area_size_meters = alert_size_to_meters($_GET['area_size']);
            //$os_ref = new OSRef($xy[0] - $area_size_meters, $xy[1] - $area_size_meters);
            //$long_lat = $os_ref->toLatLng();
            //$this->bottom_left_long = $long_lat->lng;
            //$this->bottom_left_lat = $long_lat->lat;            
            
            //top right
            //$area_size_meters = alert_size_to_meters($_GET['area_size']);
            //$os_ref = new OSRef($xy[0] + $area_size_meters, $xy[1] + $area_size_meters);
            //$long_lat = $os_ref->toLatLng();
            //$this->top_right_long = $long_lat->lng;
            //$this->top_right_lat = $long_lat->lat;
            
            // Override the rectangle coordinates
            // Very very rough approximation here of conversion from meters to miles to radians
            // Doesn't produce a square area on Google maps so it's bound to be wrong, but it will do
            // for the time being
            $lat_size = $area_size_meters * 0.000621371192 / 69.1;
            $lng_size = $area_size_meters * 0.000621371192 / 53.0;
            
            $this->bottom_left_long = $lng - $lng_size;
            $this->bottom_left_lat = $lat - $lat_size;
            $this->top_right_long = $lng + $lng_size;
            $this->top_right_lat = $lat + $lat_size;
            
        }

    }

	//Bind
	function bind () {
	    
		//page vars
		$form_action = $_SERVER['PHP_SELF'];

		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
        
		$smarty->assign("warnings", $this->warnings);
		$smarty->assign("center_long", $this->center_long);
		$smarty->assign("center_lat", $this->center_lat);		
		$smarty->assign("bottom_left_long", $this->bottom_left_long);
		$smarty->assign("bottom_left_lat", $this->bottom_left_lat);		
		$smarty->assign("top_right_long", $this->top_right_long);
		$smarty->assign("top_right_lat", $this->top_right_lat);
		$smarty->assign("warnings", $this->warnings);
		$smarty->assign("google_maps_key", GOOGLE_MAPS_KEY);
	
		//Render
		$smarty->display('preview.tpl');
		
	}

}



?>