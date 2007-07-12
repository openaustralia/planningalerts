<?php /* Smarty version 2.6.16, created on 2007-06-16 16:51:50
         compiled from rss.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'date_format', 'rss.tpl', 12, false),)), $this); ?>
<?php echo '<?xml'; ?>
 version="1.0" encoding="UTF-8"<?php echo '?>'; ?>

<rss version="2.0" xmlns:georss="http://www.georss.org/georss">
	<channel>
		<title>PlanningAlerts.com</title>
		<link>http://www.planningalerts.com/</link>
		<description></description>
        <?php $_from = ($this->_tpl_vars['applications']); if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }$this->_foreach['applications'] = array('total' => count($_from), 'iteration' => 0);
if ($this->_foreach['applications']['total'] > 0):
    foreach ($_from as $this->_tpl_vars['application']):
        $this->_foreach['applications']['iteration']++;
?>
            <item>
                <title><?php echo $this->_tpl_vars['application']->address; ?>
</title>
                <pubDate><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->date_scraped)) ? $this->_run_mod_handler('date_format', true, $_tmp, "%a, %B %e, %Y") : smarty_modifier_date_format($_tmp, "%a, %B %e, %Y")); ?>
</pubDate>                
                <guid isPermaLink="false"><?php echo $this->_tpl_vars['application']->council_reference; ?>
</guid>
                <georss:featurename><?php echo $this->_tpl_vars['application']->address; ?>
</georss:featurename>
                <georss:point><?php echo $this->_tpl_vars['application']->lat; ?>
 <?php echo $this->_tpl_vars['application']->lon; ?>
</georss:point>
                <description><![CDATA[<?php echo $this->_tpl_vars['application']->description; ?>
]]></description>
                <link><![CDATA[<?php echo $this->_tpl_vars['application']->info_url; ?>
]]></link>
                <comments><![CDATA[<?php echo $this->_tpl_vars['application']->comment_url; ?>
]]></comments>
            </item>
        <?php endforeach; endif; unset($_from); ?>
    </channel>
</rss>