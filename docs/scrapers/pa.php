<?php

require_once('../include/application.php');

# List of councils that use Public Access
# REF => array(URL, NAME)
$councils = array(
'argyll' => array("http://www.argyll-bute.gov.uk/PublicAccess/tdc/", "Argyll and Bute Council"),
'bedford' => array("http://www.publicaccess.bedford.gov.uk/publicaccess/dc/", 'Bedford Borough Council'),
'bexley' => array("http://publicaccess.bexley.gov.uk/publicaccess/tdc/", "London Borough of Bexley"),
'bradford' => array("http://www.planning4bradford.com/publicaccess/tdc/", "Bradford Metropolitan District Council"),
'cambridge' => array("http://www.cambridge.gov.uk/publicaccess/tdc/", "Cambridge City Council"),
'chester-le-street' => array("http://planning.chester-le-street.gov.uk/publicaccess/tdc/", "Chester-le-Street District Council"),
'corby' => array("http://publicaccess.corby.gov.uk/publicaccess/tdc/", "Corby Borough Council"),
'dartford' => array("http://publicaccess.dartford.gov.uk/publicaccess/tdc/", "Dartford Borough Council"),
'doncaster' => array("http://maps.doncaster.gov.uk/publicaccess/tdc/", "Doncaster Metropolitan Borough Council"),
'eastcambs' => array("http://pa.eastcambs.gov.uk/publicaccess/tdc/", "East Cambridgeshire District Council"),
'eastriding' => array("http://www.eastriding.gov.uk/PublicAccess731c/dc/", "East Riding of Yorkshire Council"),
'gloucester' => array("http://www.glcstrplnng11.co.uk/publicaccess/tdc/", "Gloucester City Council"),
'horsham' => array("http://publicaccess.horsham.gov.uk/publicaccess/tdc/", "Horsham District Council"),
'lambeth' => array("http://planning.lambeth.gov.uk/publicaccess/dc/", "London Borough of Lambeth"),
'leeds' => array("http://planningapplications.leeds.gov.uk/publicaccess/tdc/", "Leeds City Council"),
'manchester' => array("http://www.publicaccess.manchester.gov.uk/publicaccess/tdc/", "City of Manchester"),
'midsussex' => array("http://dc.midsussex.gov.uk/PublicAccess/tdc/", "Mid Sussex District Council"),
'staffordshire' => array("http://62.173.124.237/publicaccess/tdc/", "Staffordshire Moorlands District Council"),
'newham' => array("http://pacaps.newham.gov.uk/publicaccess/tdc/", "London Borough of Newham"),
'ne-derbyshire' => array("http://planapps-online.ne-derbyshire.gov.uk/publicaccess/dc/", "North East Derbyshire District Council"),
'norwich' => array("http://publicaccess.norwich.gov.uk/publicaccess/tdc/", "Norwich City Council"),
'oxford' => array("http://uniformpublicaccess.oxford.gov.uk/publicaccess/tdc/", "City of Oxford"),
'reading' => array("http://planning.reading.gov.uk/publicaccess/tdc/", "Reading Borough Council"),
'richmondshire' => array("http://publicaccess.richmondshire.gov.uk/PublicAccess/tdc/", "Richmondshire District Council"),
'rochford' => array("http://62.173.68.168/publicaccess/dc/", "Rochford District Council"),
'salford' => array("http://publicaccess.salford.gov.uk/publicaccess/dc/", "Salford City Council"),
'sandwell' => array("http://webcaps.sandwell.gov.uk/publicaccess/tdc/", "Sandwell Metropolitan Borough Council"),
'borders' => array("http://eplanning.scotborders.gov.uk/publicaccess/tdc/", "Scottish Borders Council"),
'stafford' => array("http://www3.staffordbc.gov.uk/publicaccess/tdc/", "Stafford Borough Council"),
'swindon' => array("http://194.73.99.13/publicaccess/tdc/", "Swindon Borough Council"),
'threerivers' => array("http://www2.threerivers.gov.uk/publicaccess/tdc/", "Three Rivers District Council"),
'torridge' => array("http://www.torridge.gov.uk/publicaccess/tdc/", "Torridge District Council"),
'tunbridgewells' => array("http://secure.tunbridgewells.gov.uk/publicaccess/tdc/", "Tunbridge Wells Borough Council"),
'whitehorse' => array("http://planning.whitehorsedc.gov.uk/publicaccess/tdc/", "Vale Of White Horse District Council"),
'wakefield' => array("http://planning.wakefield.gov.uk/publicaccess/tdc/", "Wakefield Metropolitan District Council"),
'westwiltshire' => array("http://planning.westwiltshire.gov.uk/PublicAccess/tdc/", "West Wiltshire District Council"),
'worthing' => array("http://planning.worthing.gov.uk/publicaccess/tdc/", "Worthing Borough Council"),
'wycombe' => array("http://planningpa.wycombe.gov.uk/publicaccess/tdc/", "Wycombe District Council"),
);

$current_date = getdate();
$day = isset($_GET['day']) ? $_GET['day'] : $current_date['mday'] - 5;
$month = isset($_GET['month']) ? $_GET['month'] : $current_date['mon'];
$year = isset($_GET['year']) ? $_GET['year'] : $current_date['year'];
$date = date('d%2\Fm%2\FY', mktime(12, 0, 0, $month, $day, $year)); # $day might be less than 1

$council = $_GET['council'];
if (!isset($council) || !array_key_exists($council, $councils)) exit;

list($url, $name) = $councils[$council];
$short_name = preg_replace('#( (Borough|City|District|Metropolitan|County))* Council#', '', $name);
$short_name = str_replace(array('London Borough of ', 'City of '), '', $short_name);

$search_url = $url . 'DcApplication/application_searchresults.aspx?searchtype=WEEKLY&selWeeklyListRange='
    . $date . '%7C' . $date . '&weektype=VAL';
$info_url_base = $url . 'DcApplication/application_detailview.aspx?caseno=';
$comment_url_base = $url . 'DcApplication/application_comments_entryform.aspx?caseno=';

$applications = scrape_applications_publicaccess($search_url, $info_url_base, $comment_url_base);
display_applications($applications, $name, $short_name);
