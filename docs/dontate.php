<?php 
    require_once ("config.php"); 
    require_once ("stats.php"); 
            

class donate_page {

	//Constructor
	function donate_page() {
		$this->bind();
	}

	//howto
	function bind() {
	    
		$smarty = new Smarty;
		$smarty->force_compile = true;
		$smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
		$smarty->assign("stats", stats::get_stats());
		$smarty->assign("page_title","Donate to the Planning Alerts server fund");
		$smarty->assign("menu_item","signup");

		$smarty->display('donate.tpl');
	}

}


$donate_page = new donate_page();