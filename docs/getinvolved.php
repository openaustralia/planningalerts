<?php 
    require_once ("config.php"); 
    require_once ("stats.php"); 
 
$getinvolved_page = new getinvolved_page();

class getinvolved_page {

	//Constructor
	function getinvolved_page() {	
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
		$smarty->assign("page_title","Get involved");		
		$smarty->assign("menu_item", "getinvolved");	
		//Render
		$smarty->display('getinvolved.tpl');
		
	}

}



?>