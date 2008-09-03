<?php
//
// Scraper for Wealden District Council Planning Website
// Created by Matt Ford on Sunday 24th August 2008
//
// The script works according to requirements of PlanningAlerts.com
// The default output is according to PlanningAlerts requirements,
// to get all the data add 'all=true' to the end of the query string
//
// You need to set the location of the 'cookie jar'  for the scraper to work

// This is truly horrible - the tempnam function can't be called without
// the arguments in order to get the system temporary directory, but it falls
// back on it if the first argument doesn't exist - Duncan
$cookiejar = tempnam('nonexistantdirectory', '');

//Check a day is set and is valid
$day = (isset($_GET['day']) && !empty($_GET['day']) && $_GET['day'] > 0 && $_GET['day'] < 32) ? $_GET['day'] : 1;

//Check a month is set and is valid
$month = (isset($_GET['month']) && !empty($_GET['month']) && $_GET['month'] > 0 && $_GET['month'] < 13) ? $_GET['month'] : 1;

//Check a year is set and is valid
$year = (isset($_GET['year']) && !empty($_GET['year']) && $_GET['year'] > 2003 && $_GET['year'] <= gmdate('Y')) ? $_GET['year'] : gmdate('Y');

//Do you want all information or only the common stuff?
$all = (isset($_GET['all']) && $_GET['all'] != false) ? true : false;

$date = $day.'/'.$month.'/'.$year;

$applications = array();

function fetch_page($url,$post_string = false,$post_count = false) {
	if(!isset($ch)) {
		$ch = curl_init();
	}
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_REFERER, $url);	
	curl_setopt($ch, CURLOPT_COOKIEJAR, $cookiejar);
	curl_setopt($ch, CURLOPT_COOKIEFILE, $cookiejar);
	if($post_count > 0) {
		curl_setopt($ch, CURLOPT_POST, $post_count);
		curl_setopt($ch, CURLOPT_POSTFIELDS,$post_string);		
	}
	$data = curl_exec($ch);
	return $data;
}

function extract_data($string) {
	list($junk,$return) = explode('</h5>',$string);
	return trim(strip_tags($return));
}

function parse_search($date,$page_no=1,$AppRef='') {
	global $applications;

	$url = 'http://www.planning.wealden.gov.uk/aspxpages/SearchResults.aspx?pageno='.$page_no.'&QueryType=9&WeekNo=&WeekStart=&WeekEnd=&CaseNo=&Add=&ShowInd=&DocId=&AppRef='.$AppRef.'&Category=DC&DateType=R&StartDate='.$date.'&EndDate='.$date.'&Agent=&ParishCode=&WardCode=&Parish=&Ward=&AdvAppNo=&AdvAdd=&AdvProposal=&DecisionCode=&Det=';
	//echo 'Loading page '.$page_no.' of data for '.$date.' URL:'.$url.'<br />';

	$data = fetch_page($url);
	if(strpos($data,"<title>Wealden District Council's applications online - Copyright, disclaimer & personal data</title>")) {
		//Accept their terms
		list($junk,$viewstate) = explode('<input type="hidden" name="__VIEWSTATE" value="',$data,2);
		list($viewstate,$junk) = explode('" />',$viewstate,2);
		//echo 'Attempting to bypass copyright page...<br />';
		$url = 'http://www.planning.wealden.gov.uk/aspxpages/Copyright.aspx?pageno='.$page_no.'&QueryType=9&WeekNo=&WeekStart=&WeekEnd=&CaseNo=&Add=&ShowInd=&DocId=&AppRef='.$AppRef.'&Category=DC&DateType=R&StartDate='.$date.'&EndDate='.$date.'&Agent=&ParishCode=&WardCode=&Parish=&Ward=&AdvAppNo=&AdvAdd=&AdvProposal=&DecisionCode=&Det=';
		$data = fetch_page($url,'btnCopyrightAccept=Accept&__VIEWSTATE='.urlencode($viewstate).'',2);
	}
	list($junk,$data) = explode('<span id="lblSearchResults">', $data);
	list($data,$next_page) = explode('<div id="pagenumbers">',$data);
	$data = explode('</ul>',$data);
	unset($data[10]);
	foreach($data as $application) {
		$application = explode('</li>',$application);
		$AppNo = extract_data($application[0]);
		if(!empty($AppNo)) {
			$applications[$AppNo]['AppNo'] = $AppNo;
			$Loc = extract_data($application[1]);
			$applications[$AppNo]['Address'] = $Loc;
			preg_match("/([A-Z]{1,2}[0-9][0-9A-Z]?\s?[0-9][A-Z]{2})/",$Loc,$PostCode);
			if(isset($PostCode[1])) {
				$applications[$AppNo]['PostCode'] = $PostCode[1];
			} else {
				$applications[$AppNo]['PostCode'] = false;
			}
			$applications[$AppNo]['Info'] = extract_data($application[2]);
			parse_detail($AppNo);
		}
	}
	if(strpos($next_page,'Next</a></div></span> <br />')) {
		$page_no++;
		//echo "Loading next page...";
		if($page_no < 6) {
			parse_search($date,$page_no,$AppNo);
		}
	}
}

function parse_detail($AppNo) {
	global $applications;
	$url = 'http://www.planning.wealden.gov.uk/aspxpages/ResultsDetail.aspx?appref='.$AppNo.'&Category=DC';
	list($junk,$data) = explode('<span id="lblSearchDetails">',fetch_page($url),2);
	list($data,$junk) = explode('<div class="linkborder">',$data,2);
	$data = explode('</li>',$data);
	$applications[$AppNo]['AppType'] = extract_data($data[1]);
	$applications[$AppNo]['DateRec'] = extract_data($data[2]);
	$applications[$AppNo]['DateExp'] = extract_data($data[3]);
	$applications[$AppNo]['Parish'] = extract_data($data[6]);
	$applications[$AppNo]['GridRef'] = extract_data($data[7]);
	$applications[$AppNo]['UPRN'] = extract_data($data[8]);
	list($status,$junk) = explode(' - ',extract_data($data[9]));
	$applications[$AppNo]['Status'] = trim($status);
	$applications[$AppNo]['DateConExp'] = extract_data($data[10]);
	$applications[$AppNo]['DateComDel'] = extract_data($data[11]);
	$applications[$AppNo]['Decision'] = extract_data($data[12]);
	$applications[$AppNo]['DateDec'] = extract_data($data[13]);
	$applications[$AppNo]['CaseOfficer'] = extract_data($data[14]);
}
parse_search($date);

header("Content-Type: text/xml");
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
echo "<planning>\n";
echo "\t<authority_name>Wealden District Council</authority_name>\n";
echo "\t<authority_short_name>Wealden</authority_short_name>\n";
echo "\t<applications>\n";
foreach($applications as $application) {
	echo "\t\t<application>\n";
	echo "\t\t\t<council_reference>".$application['AppNo']."</council_reference>\n";
	echo "\t\t\t<address>".$application['Address']."</address>\n";
	echo "\t\t\t<postcode>".$application['PostCode']."</postcode>\n";
    echo "\t\t\t<description>".$application['Info']."</description>\n";
    echo "\t\t\t<info_url><![CDATA[http://www.planning.wealden.gov.uk/aspxpages/ResultsDetail.aspx?appref=".$application['AppNo']."&Category=DC]]></info_url>\n";
	echo "\t\t\t<comment_url>planning@wealden.gov.uk</comment_url>\n";
	echo "\t\t\t<date_received>".$application['DateRec']."</date_received>\n";
	if($all) {
		echo "\t\t\t<application_type>".$application['AppType']."</application_type>\n";
		echo "\t\t\t<date_expires>".$application['DateExp']."</date_expires>\n";
		echo "\t\t\t<parish>".$application['Parish']."</parish>\n";
		echo "\t\t\t<grid_reference>".$application['GridRef']."</grid_reference>\n";
		echo "\t\t\t<uprn>".$application['UPRN']."</uprn>\n";
		echo "\t\t\t<status>".$application['Status']."</status>\n";
		echo "\t\t\t<consultation_expiry_date>".$application['DateConExp']."</consultation_expiry_date>\n";
		echo "\t\t\t<committee_delegated_date>".$application['DateComDel']."</committee_delegated_date>\n";
		echo "\t\t\t<decision>".$application['Decision']."</decision>\n";
		echo "\t\t\t<decision_date>".$application['DateDec']."</decision_date>\n";
		echo "\t\t\t<case_officer>".$application['CaseOfficer']."</case_officer>\n";
	}
	echo "\t\t</application>\n";
}
echo "\t</applications>\n";
echo "</planning>";
?>

