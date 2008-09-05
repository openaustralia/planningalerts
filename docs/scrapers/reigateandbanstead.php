<?php
//
// Scraper for Reigate &  Banstead
// Created by Matt Ford on Tue 2nd September 2008
//
// The script works according to requirements of PlanningAlerts.com
//

//Check a day is set and is valid
$day = (isset($_GET['day']) && !empty($_GET['day']) && $_GET['day'] > 0 && $_GET['day'] < 32) ? $_GET['day'] : 1;

//Check a month is set and is valid
$month = (isset($_GET['month']) && !empty($_GET['month']) && $_GET['month'] > 0 && $_GET['month'] < 13) ? $_GET['month'] : 1;

//Check a year is set and is valid
$year = (isset($_GET['year']) && !empty($_GET['year']) && $_GET['year'] > 2003 && $_GET['year'] <= gmdate('Y')) ? $_GET['year'] : gmdate('Y');

$xml = array(    'name' => 'Reigate and Banstead',
        'full_name' => 'Reigate and Banstead Borough Council',
        'url' => 'http://www.reigate-banstead.gov.uk/Planit2/planit2.jsp',
        'detail_url' => 'http://www.reigate-banstead.gov.uk/Planit2/planit2.jsp?Controller=p2Controller&Action=FindApplicationByRefvalAction&REFVAL=',
        'comments' => 'http://www.reigate-banstead.gov.uk/Planit2/planit2.jsp?Controller=p2Controller&Action=ShowCommentFormAction&REFVAL=');

$months = array(
    '1' => 'JAN',
    '2' => 'FEB',
    '3' => 'MAR',
    '4' => 'APR',
    '5' => 'MAY',
    '6' => 'JUN',
    '7' => 'JUL',
    '8' => 'AUG',
    '9' => 'SEP',
    '10' => 'OCT',
    '11' => 'NOV',
    '12' => 'DEC');

$month = $months[$month];
    
$applications = array();

function fetch_page($url) {
    if(!isset($ch)) {
        $ch = curl_init();
    }
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_REFERER, $url);    
    $data = curl_exec($ch);
    return $data;
}

function parse_search($page = 1) {
    global $applications,$day,$month,$year,$xml;
    
    $start = ($page * 10) - 19;
    if($start < 0) $start = 1;
    if($page == '2') {
        $shown = 'Y';
        $start = 1;
    } else {
        $shown = 'N';
    }
        
    $url = $xml['url'].'?Controller=p2Controller&Action=FindApplicationsByDatesAction&START_DD='.$day.'&START_MMM='.$month.'&START_YYYY='.$year.'&END_DD='.$day.'&END_MMM='.$month.'&END_YYYY='.$year.'&WARD=ALL&CURR=&DECSN=&START_ROW='.$start.'&FIRST_TEN_SHOWN='.$shown.'&SEARCH_DIRECTION=F';
    //echo 'Loading page '.$page.' of data from URL:'.$url.'<br />';

    $data = explode('<div class="result">',fetch_page($url));
    unset($data[0]);
    foreach($data as $app) {
        $app = explode('</span>',$app);
        $AppNo = trim(strip_tags($app[0]));
        $applications[$AppNo]['AppNo'] = $AppNo;
        list($info,$address) = explode('<br/>',$app[2]);
        $applications[$AppNo]['Info'] = trim(strip_tags($info));
        $applications[$AppNo]['Address'] = trim(strip_tags($address));
        preg_match("/([A-Z]{1,2}[0-9][0-9A-Z]?\s?[0-9][A-Z]{2})/",$address,$PostCode);
        if(isset($PostCode[1])) {
            $applications[$AppNo]['PostCode'] = $PostCode[1];
        } else {
            $applications[$AppNo]['PostCode'] = false;
        }
        parse_detail($AppNo);
    }
    if(strpos($app[2],'alt="Next 10 applications"')) {
        parse_search($page+1);
    }
}

function parse_detail($AppNo) {
    global $applications,$xml;
    $url = $xml['detail_url'].$AppNo;
    list($junk,$DateRec) = explode('<th class="type">Date Received</th>',fetch_page($url));
    list($DateRec,$junk) = explode('</td>',$DateRec,2);
    $applications[$AppNo]['DateRec'] = date('d/m/Y',strtotime(trim(strip_tags($DateRec))));
}

parse_search();

header("Content-Type: text/xml");
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
echo "<planning>\n";
echo "\t<authority_name>".$xml['full_name']."</authority_name>\n";
echo "\t<authority_short_name>".$xml['name']."</authority_short_name>\n";
echo "\t<applications>\n";
foreach($applications as $application) {
    echo "\t\t<application>\n";
    echo "\t\t\t<council_reference>".$application['AppNo']."</council_reference>\n";
    echo "\t\t\t<address><![CDATA[".$application['Address']."]]></address>\n";
    echo "\t\t\t<postcode>".$application['PostCode']."</postcode>\n";
    echo "\t\t\t<description><![CDATA[".$application['Info']."]]></description>\n";
    echo "\t\t\t<info_url><![CDATA[".$xml['detail_url'].$application['AppNo']."]]></info_url>\n";
    echo "\t\t\t<comment_url><![CDATA[".$xml['comments'].$application['AppNo']."]]></comment_url>\n";
    echo "\t\t\t<date_received>".$application['DateRec']."</date_received>\n";
    echo "\t\t</application>\n";
}
echo "\t</applications>\n";
echo "</planning>";
?>








