<?php /* Smarty version 2.6.16, created on 2008-09-28 20:51:25
         compiled from header.tpl */ ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title>PlanningAlerts.com | <?php echo $this->_tpl_vars['page_title']; ?>
</title>
	<link rel="stylesheet" media="all" type="text/css" href="./css/memespring.css" />		
	<link rel="stylesheet" media="all" type="text/css" href="./css/main.css" />
    <script src="./javascript/main.js" type="text/javascript"></script>      	
	
</head>

<body>

    <div class="hide">
        <a href="#divContent">Skip navigation</a>
    </div>
    <div id="divMenu">
        <ul class="collapse">
            <li <?php if ($this->_tpl_vars['menu_item'] == 'about'): ?>class="selected"<?php endif; ?>><a href="about.php">About</a></li>                                     
			<li <?php if ($this->_tpl_vars['menu_item'] == 'api'): ?>class="selected"<?php endif; ?>><a href="apihowto.php">API</a></li>

            <li <?php if ($this->_tpl_vars['menu_item'] == 'getinvolved'): ?>class="selected"<?php endif; ?>><a href="getinvolved.php">Get involved</a></li>                                       
            <li <?php if ($this->_tpl_vars['menu_item'] == 'faq'): ?>class="selected"<?php endif; ?>><a href="faq.php"><acronym title="Frequently asked questions">FAQ</acronym>s</a></li>                
            <li <?php if ($this->_tpl_vars['menu_item'] == 'signup'): ?>class="selected"<?php endif; ?>><a href="/">Signup</a></li>            
        </ul>
    </div>
    <div id="divPage">
        <div id="divHeader">
            <h1><a href="/">PlanningAlerts<span>.</span>com</a><small>beta</small></h1>
            <h2>Email alerts of planning applications <em>near you</em></h2>
            <p id="pStats"><?php echo $this->_tpl_vars['stats']['alert_count']; ?>
 alerts sent for <?php echo $this->_tpl_vars['stats']['authority_count']; ?>
 local authorities</p>
            <img alt="logo" title="logo" src="./images/logo.png" />
        </div>
        <div id="divContent">
            <div id="divWarning" <?php if ($this->_tpl_vars['warnings'] == ""): ?>class="hide"<?php endif; ?>>
                <?php echo $this->_tpl_vars['warnings']; ?>

            </div>
            