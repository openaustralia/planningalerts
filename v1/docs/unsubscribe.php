<?php 
    require_once ("config.php"); 
    require_once ("user.php");     
    require_once ("stats.php"); 

$unsubscribe_page = new unsubscribe_page;

class unsubscribe_page {

    //Properties
    var $address = "";
    var $area_size_meters = 0;
    
	//Constructor
	function unsubscribe_page() {	
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
        if ($user->load_from_confirm_id($confirm_id)){

            //Grab the address and area
            $this->address = $user->address;
            $this->area_size_meters = $user->area_size_meters;
        
            //delete the user
            $user->delete();
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
		$smarty->assign("page_title","Unsubscribed");		
		$smarty->assign("address", $this->address);
		$smarty->assign("area_size_meters", $this->area_size_meters);		

		//Render
		$smarty->display('unsubscribe.tpl');
		
	}
	
}



?>