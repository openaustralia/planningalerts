<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title>PlanningAlerts.org.au | {$page_title}</title>
	<link rel="stylesheet" media="all" type="text/css" href="./stylesheets/memespring.css" />		
	<link rel="stylesheet" media="all" type="text/css" href="./stylesheets/main.css" />
    <script src="./javascripts/main.js" type="text/javascript"></script>      	

    <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '{$smarty.const.GOOGLE_ANALYTICS_KEY}']);
      _gaq.push(['_trackPageview']);
      {literal}(function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
      })();{/literal}
    </script>	
</head>
<body>

    <div id="divHeader">
        <h1><a href="/">PlanningAlerts<span>.</span>org<span>.</span>au</a><sup>beta</sup></h1>
        <h2>Email alerts of planning applications <em>near you</em></h2>
        <div id="statsbanner"><p id="pStats">{$stats.alert_count} alerts sent for <a href="/about.php#authorities">{$stats.authority_count} authorities</a></p></div>
    </div>
    <div class="hide">
        <a href="#divContent">Skip navigation</a>
    </div>
    <div id="divMenu">
        <ul class="collapse">
            <li {if $menu_item =="about"}class="selected"{/if}><a href="/about.php">About</a></li>                                     
			<li {if $menu_item == "api"}class="selected"{/if}><a href="/apihowto.php"><acronym title="Application programming interface">API</acronym></a></li>

            <li {if $menu_item =="getinvolved"}class="selected"{/if}><a href="/getinvolved.php">Get Involved</a></li>                                       
            <li {if $menu_item =="faq"}class="selected"{/if}><a href="/faq.php"><acronym title="Frequently asked questions">FAQ</acronym></a></li>                
            <li {if $menu_item =="signup"}class="selected"{/if}><a href="/">Sign Up</a></li>            
        </ul>
    </div>
    <div id="divPage">
        <div id="divContent">
            <div id="divWarning" {if $warnings == ""}class="hide"{/if}>
                {$warnings}
            </div>
            
