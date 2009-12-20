<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title>PlanningAlerts.org.au | {$page_title}</title>
	<link rel="stylesheet" media="all" type="text/css" href="./css/memespring.css" />		
	<link rel="stylesheet" media="all" type="text/css" href="./css/main.css" />
    <script src="./javascript/main.js" type="text/javascript"></script>      	
	
</head>
{literal}<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("{/literal}{$smarty.const.GOOGLE_ANALYTICS_KEY}{literal}");
pageTracker._trackPageview();
} catch(err) {}</script>{/literal}
<body>

    <div id="divHeader">
        <h1><a href="/">PlanningAlerts<span>.</span>org<span>.</span>au</a><sup>beta</sup></h1>
        <h2>Email alerts of planning applications <em>near you</em></h2>
        <!-- <p id="pStats">{$stats.alert_count} alerts sent for {$stats.authority_count} planning authorities</p> -->
    </div>
    <div class="hide">
        <a href="#divContent">Skip navigation</a>
    </div>
    <div id="divMenu">
        <ul class="collapse">
            <li {if $menu_item =="about"}class="selected"{/if}><a href="about.php">About</a></li>                                     
			<li {if $menu_item == "api"}class="selected"{/if}><a href="apihowto.php"><acronym title="Application programming interface">API</acronym></a></li>

            <li {if $menu_item =="getinvolved"}class="selected"{/if}><a href="getinvolved.php">Get Involved</a></li>                                       
            <li {if $menu_item =="faq"}class="selected"{/if}><a href="faq.php"><acronym title="Frequently asked questions">FAQ</acronym></a></li>                
            <li {if $menu_item =="signup"}class="selected"{/if}><a href="/">Sign Up</a></li>            
        </ul>
    </div>
    <div id="divPage">
        <div id="divContent">
            <div id="divWarning" {if $warnings == ""}class="hide"{/if}>
                {$warnings}
            </div>
            
