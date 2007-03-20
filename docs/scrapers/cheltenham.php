<?php

//Includes
require_once('config.php');
require_once('application.php');

if (isset($_GET['day'])){
    $day = $_GET['day'];
}
if (isset($_GET['month'])){
    $month = $_GET['month'];
}
if (isset($_GET['year'])){
    $year = $_GET['year'];
}

	//search url
	$search_url = "http://planning.cheltenham.gov.uk/PublicAccess/tdc/DcApplication/application_searchresults.aspx?searchtype=WEEKLY&selWeeklyListRange=#daterange&weektype=VAL";
    $date_range = "{$day}%2F{$month}%2F{$year}%7C{$day}%2F{$month}%2F{$year}";
	$search_url = str_replace("#daterange", $date_range, $search_url);

	//comment and info urls
	$info_url_base = "http://planning.cheltenham.gov.uk/PublicAccess/tdc/DcApplication/application_detailview.aspx?caseno=";
	$comment_url_base = "http://planning.cheltenham.gov.uk/PublicAccess/tdc/DcApplication/application_comments_entryform.aspx?caseno=";
	
    //grab urls
	$applications = scrape_applications_publicaccess($search_url, $info_url_base, $comment_url_base);

    //Display applications
    display_applications($applications, "Cheltenham Borough Council", "Cheltenham Borough");

?>
