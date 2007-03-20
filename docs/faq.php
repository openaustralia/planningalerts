<?php 
    require_once ("config.php"); 
 
$faq_page = new faq_page;

class faq_page {

	//Constructor
	function faq_page() {	
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

		$smarty->assign("page_title","Frequently asked questions");		
		$smarty->assign("menu_item", "faq");	
		//Render
		$smarty->display('faq.tpl');
		
	}

}



?>