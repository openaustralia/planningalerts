<?php

    //includes
    require_once('config.php');
    require_once('application_parser.php');
    require_once('mailer.php');   
        
    if (!isset($_GET['action'])){
        print "nothing to see here.";
    }else{
        echo "starting action " . $_GET['action'];
    }
    
    $action = $_GET['action'];
    
    if($action == "scrape"){
    
        //Launch the parser
        $application_parser = new application_parser();
        $application_parser->date = getdate(strtotime("-" . SCRAPE_DELAY . " days"));
        $application_parser->run();  

          
    }
    
    if ($action == "mail"){
        //Launch the mailer
        $mailer = new mailer();
        $mailer->run();
    }


?>