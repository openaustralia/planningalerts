<?php
print get_include_path();
    //add the absolute include paths
    set_include_path(get_include_path() . ":" . dirname(__FILE__) . '/../docs/include' . ":" . dirname(__FILE__) . '/../docs/include/PEAR');

	//add conf file for the main web app
    require_once('config.php');

?>