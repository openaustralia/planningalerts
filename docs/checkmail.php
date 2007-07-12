<?php 
    require_once ("config.php"); 
    require_once ("user.php");     
    require_once ("stats.php"); 

$checkmail_page = new checkmail_page;

class checkmail_page {

	//Constructor
	function checkmail_page() {	
	    $this->bind();
    }
	
	//Bind
	function bind() {
	    
		//page vars
		$form_action = $_SERVER['PHP_SELF'];
		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
		$smarty->assign("stats", stats::get_stats());
		$smarty->assign("page_title","Now check your email");		
		$smarty->assign("menu_item", "signup");	
		//Render
		$smarty->display('checkmail.tpl');
		
	}

}



?>