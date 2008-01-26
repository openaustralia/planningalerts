<?php

//Includes
require_once('config.php');
require_once('application.php');

//build date url
$current_date = getdate();
$day = $current_date['mday'] -5;
$month = $current_date['mon'];
$year = $current_date['year'];

//if any get params were passed, overwrite the default date
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
	$search_url = "http://planning.sheffield.gov.uk/publicaccess/tdc/DcApplication/application_searchresults.aspx?searchtype=WEEKLY&selWeeklyListRange=#daterange&weektype=VAL";
    $date_range = "{$day}%2F{$month}%2F{$year}%7C{$day}%2F{$month}%2F{$year}";
	$search_url = str_replace("#daterange", $date_range, $search_url);
	
	//comment and info urls
	$info_url_base = "http://212.56.70.100/publicaccess/tdc/DcApplication/application_detailview.aspx?caseno=";
	$comment_url_base = "http://212.56.70.100/publicaccess/tdc/DcApplication/application_comments_entryform.aspx?caseno=";
	
    //grab urls
	$applications = scrape_applications_publicaccess($search_url, $info_url_base, $comment_url_base);

    //Display applications
    display_applications($applications, "Sheffield City Council", "Sheffield");

?>
