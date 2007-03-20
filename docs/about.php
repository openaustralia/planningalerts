<?php 
    require_once ("config.php"); 
    require_once ("DB.php");    
 
$about_page = new about_page;

class about_page {

    //Properties
    var $authorities = array();

	//Constructor
	function about_page() {	
	    $this->setup();	    
	    $this->bind();
    }
	
	//Setup
	function setup (){
	    
	     $db = DB::connect(DB_CONNECTION_STRING);
	     
	    //Grab a list of local authorities
	    $sql = "Select full_name, disabled from authority where disabled = 0 or disabled is null order by full_name";
	    $results =  $db->getAll($sql);
	
	    for ($i=0; $i < sizeof($results); $i++){ 
	       array_push($this->authorities, $results[$i][0]);
	    }
	    
    }
	
	//Bind
	function bind() {
	    
		//page vars
		$form_action = $_SERVER['PHP_SELF'];
		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;

		$smarty->assign("page_title","About");		
		$smarty->assign("menu_item", "about");	
	
		$smarty->assign("authorities",$this->authorities);	
			
		//Render
		$smarty->display('about.tpl');
		
	}

}



?>