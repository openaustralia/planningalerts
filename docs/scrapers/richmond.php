<?php
//
// Scraper for Richmond
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

$xml = array(    'name' => 'Richmond',
        'full_name' => 'London Borough of Richmond upon Thames',
        'url' => 'http://www2.richmond.gov.uk/PlanData2/planning_summary.aspx',
        'detail_url' => 'http://www2.richmond.gov.uk/PlanData2/Planning_CaseNo.aspx?strCASENO=',
        'comments' => 'http://forms.richmond.gov.uk/AF3/an/default.aspx/RenderForm/?F.Name=C5aG_poZZFP');

$date = $day.'/'.$month.'/'.$year;

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

function parse_search($date) {
    global $applications;

    $url = 'http://www2.richmond.gov.uk/PlanData2/planning_summary.aspx?strRecTo='.$date.'&strRecFrom='.$date;
    //echo 'Loading page '.$page_no.' of data for '.$date.' URL:'.$url.'<br />';

    $data = fetch_page($url);
    $data = explode('</table>',$data);
    $data = explode('</TABLE>',$data[1]);
    foreach($data as $application) {
        $application = explode('</tr>',$application);
        $detail = explode('</TD>',$application[3]);
        list($AppNo,$junk) = explode('<BR>',$detail[0]);
        $AppNo = trim(strip_tags($AppNo));
        $applications[$AppNo]['AppNo'] = $AppNo;
        $applications[$AppNo]['DateRec'] = trim(strip_tags($detail[2]));
        $applications[$AppNo]['Info'] = trim(strip_tags($detail[4]));
        $Loc = trim(strip_tags($application[1]));
        if(substr($Loc,-29) == 'Click here for a location map') {
            $Loc = substr($Loc,0,-29);
        }
        $applications[$AppNo]['Address'] = $Loc;
        preg_match("/([A-Z]{1,2}[0-9][0-9A-Z]?\s?[0-9][A-Z]{2})/",$Loc,$PostCode);
        if(isset($PostCode[1])) {
            $applications[$AppNo]['PostCode'] = $PostCode[1];
        } else {
            $applications[$AppNo]['PostCode'] = false;
        }
        if(empty($AppNo)) {
            unset($applications[$AppNo]);
        }
    }
}

parse_search($date);

header("Content-Type: text/xml");
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
echo "<planning>\n";
echo "\t<authority_name>".$xml['full_name']."</authority_name>\n";
echo "\t<authority_short_name>".$xml['name']."</authority_short_name>\n";
echo "\t<applications>\n";
foreach($applications as $application) {
    echo "\t\t<application>\n";
    echo "\t\t\t<council_reference>".$application['AppNo']."</council_reference>\n";
    echo "\t\t\t<address>".$application['Address']."</address>\n";
    echo "\t\t\t<postcode>".$application['PostCode']."</postcode>\n";
    echo "\t\t\t<description><![CDATA[".$application['Info']."]]></description>\n";
    echo "\t\t\t<info_url>".$xml['detail_url'].$application['AppNo']."</info_url>\n";
    echo "\t\t\t<comment_url>".$xml['comments']."</comment_url>\n";
    echo "\t\t\t<date_received>".$application['DateRec']."</date_received>\n";
    echo "\t\t</application>\n";
}
echo "\t</applications>\n";
echo "</planning>";
?>








