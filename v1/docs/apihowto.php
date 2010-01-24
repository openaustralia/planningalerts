<?php 
    require_once ("config.php"); 
    require_once ("stats.php"); 
            
$api = new api;

class api {

	//Constructor
	function api() {
		$this->bind();
	}

    // Turn a url for an API call into a Google Map of that data
    function mapify($url, $zoom = 13) {
        return "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=" . $zoom . "&om=1&q=" . urlencode($url);
    }
    
	//howto
	function bind() {
		$form_action = $_SERVER['PHP_SELF'];

		$smarty = new Smarty;
		$smarty->force_compile = true;
		$smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
		$smarty->assign("stats", stats::get_stats());
		$smarty->assign("page_title","API");
		$smarty->assign("menu_item","api");
		$smarty->assign("api_url", BASE_URL . "/api.php");
		
		$example_address = "24 Bruce Road Glenbrook, NSW 2773";
		$example_size = 4000;
		$example_authority = "Blue Mountains";
		// This lat/lng is for 24 Bruce Road as well
		$example_lat = -33.772609;
		$example_lng = 150.624263;
		// This covers most of Victoria and NSW
		$example_bottom_left_lat = -38.556757;
		$example_bottom_left_lng = 140.833740;
		$example_top_right_lat = -29.113775;
		$example_top_right_lng = 153.325195;
		
		$api_base = BASE_URL . "/api.php";
		$api_example_address_url = $api_base . "?call=address&address=" . urlencode($example_address) .
		    "&area_size=" . $example_size;
        $api_example_latlong_url = $api_base . "?call=point&lat=" . $example_lat . "&lng=" . $example_lng .
            "&area_size=" . $example_size;
        $api_example_area_url = $api_base . "?call=area&bottom_left_lat=" . $example_bottom_left_lat .
            "&bottom_left_lng=" . $example_bottom_left_lng . "&top_right_lat=" . $example_top_right_lat .
            "&top_right_lng=" . $example_top_right_lng;
        $api_example_authority_url = $api_base . "?call=authority&authority=" . urlencode($example_authority);
        
		$smarty->assign("api_example_address_url", $api_example_address_url);
		$smarty->assign("api_example_latlong_url", $api_example_latlong_url);
        $smarty->assign("api_example_area_url", $api_example_area_url);
        $smarty->assign("api_example_authority_url", $api_example_authority_url);

        $smarty->assign("map_example_address_url", $this->mapify($api_example_address_url, 14));
        $smarty->assign("map_example_latlong_url", $this->mapify($api_example_latlong_url, 14));
        $smarty->assign("map_example_area_url", $this->mapify($api_example_area_url, 6));
        $smarty->assign("map_example_authority_url", $this->mapify($api_example_authority_url, 11));
        
		$smarty->display('apihowto.tpl');
	}

}



?>
