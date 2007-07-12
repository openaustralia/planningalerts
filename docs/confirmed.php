<?php 
    require_once ("config.php"); 
    require_once ("user.php");     
    require_once ("stats.php"); 

$confirmed_page = new confirmed_page;

class confirmed_page {

    //Properties
    var $postcode = "";
    var $alert_area_size = 0;
    
	//Constructor
	function confirmed_page() {	
	    $this->setup();
		$this->bind();
    }
    
    //Setup
    function setup (){
        
        //Grab the user
        if(isset($_GET['cid'])){
            $confirm_id = $_GET['cid'];
        }else{
            header("HTTP/1.0 404 Not Found"); 
            exit;
        }
        
        $user = new user();
        if($user->load_from_confirm_id($confirm_id)){

            //Update the confirmed flag
            $user->confirmed = true;
        
            //delete any other active alerts for this postcode
            $user->remove_existing();

            $user->save(false);

            //Grab the postcode and area
            $this->postcode = $user->postcode;
            $this->alert_area_size =  alert_size_to_meters($user->alert_area_size);
            
        }else{
           header("HTTP/1.0 404 Not Found"); 
           exit;            
        }

    }
	
	//Bind
	function bind() {

		$form_action = $_SERVER['PHP_SELF'];
		
		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
		$smarty->assign("stats", stats::get_stats());
		$smarty->assign("menu_item", "signup");
		$smarty->assign("page_title","Confirmed");		
		$smarty->assign("form_action", $form_action);
		$smarty->assign("postcode", clean_postcode($this->postcode));
		$smarty->assign("alert_area_size", $this->alert_area_size);		

		//Render
		$smarty->display('confirmed.tpl');
		
	}
	
}



?>