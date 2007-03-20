<?php 
    require_once ("config.php"); 
    require_once ("user.php");   


$index_page = new index_page;

class index_page {

    //Properties
	var $warnings = "";
	var $onloadscript = "";
	var $postcode = "";
	var $email = "";
	var $alert_area_size = "m";
	var $email_warn = false;
	var $postcode_warn = false;	

	//Constructor
	function index_page() {
	
		//check for postback vs load
		if (isset($_POST["_is_postback"])) {
			$this->unbind();
    	    $this->process();
		}else{
		    $this->setup();
			$this->bind();
		}		
	}
	
    //setup
    function setup (){

    }

	//Bind
	function bind() {
	    
		//page vars
		$form_action = $_SERVER['PHP_SELF'];
		$this->onloadscript = "setFocus('txtEmail');";

		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
        
		$smarty->assign("menu_item", "signup");
		$smarty->assign("postcode", $this->postcode);
		$smarty->assign("email", $this->email);		
		$smarty->assign("alert_area_size", $this->alert_area_size);		
		$smarty->assign("page_title","Email alerts of planning applications near you");
		$smarty->assign("warnings", $this->warnings);
		$smarty->assign("email_warn", $this->email_warn);		
		$smarty->assign("postcode_warn", $this->postcode_warn);		
		
		$smarty->assign("onloadscript", $this->onloadscript);
		$smarty->assign("small_zone_size",SMALL_ZONE_SIZE);
		$smarty->assign("medium_zone_size",MEDIUM_ZONE_SIZE);
		$smarty->assign("large_zone_size",LARGE_ZONE_SIZE);				
		
		//Render
		$smarty->display('index.tpl');
		
	}
	
	function unbind (){

	    //Get postcode and setup the group
	    $this->postcode = $_POST['txtPostcode'];
	    $this->email = $_POST['txtEmail'];	    
	    $this->alert_area_size = $_POST['radAlertAreaSize'];	    
	    
    }
    
    function validate (){
        if($this->email =="" || !valid_email($this->email)){
            $this->email_warn = true;
            $this->warnings .= " Please enter a valid email address.";            
        }
        if($this->postcode =="" || !is_postcode($this->postcode)){
            $this->postcode_warn = true;            
            $this->warnings .= " Please enter a valid postcode.";
        }
        if($this->alert_area_size != "s" && $this->alert_area_size != "m" && $this->alert_area_size != "l"){
            $this->warnings .= " Please select an area for the alerts.";
        }
        
        return $this->warnings =="";
        
    }
    
    function process (){
        if($this->validate()){
            
            $user = new user();
            
            //Populate new user
            $user->populate_new($this->email, $this->postcode, $this->alert_area_size);
            
            //Save 
            $user->save(true);
            
            //send to check mail page
            $base_url = BASE_URL;
            header("Location: {$base_url}/checkmail.php");
        }else{
            $this->bind();
        }
    }
}



?>
