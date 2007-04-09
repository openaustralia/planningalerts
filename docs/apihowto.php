<?php 
    require_once ("config.php"); 
            
$api = new api;

class api {

	//Constructor
	function api() {
		$this->bind();
	}

	//howto
	function bind() {
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
