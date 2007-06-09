<?php /* Smarty version 2.6.16, created on 2007-05-22 18:21:22
         compiled from xml.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'escape', 'xml.tpl', 6, false),)), $this); ?>
<?php echo '<?xml'; ?>
 version="1.0" encoding="UTF-8"<?php echo '?>'; ?>

<planning>
    <authority_name>
        <?php echo ((is_array($_tmp=$this->_tpl_vars['authority_name'])) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>

    </authority_name>
    <authority_short_name>
        <?php echo ((is_array($_tmp=$this->_tpl_vars['authority_short_name'])) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>

    </authority_short_name>
    <applications>
        <?php $_from = ($this->_tpl_vars['applications']); if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }$this->_foreach['applications'] = array('total' => count($_from), 'iteration' => 0);
if ($this->_foreach['applications']['total'] > 0):
    foreach ($_from as $this->_tpl_vars['application']):
        $this->_foreach['applications']['iteration']++;
?>
            <application>
                <council_reference><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->council_reference)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</council_reference>
                <address><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->address)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</address>
                <postcode><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->postcode)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</postcode>
                <description><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->description)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</description>
                <info_url><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->info_url)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</info_url>
                <comment_url><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->comment_url)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</comment_url>
                <date_received><?php echo ((is_array($_tmp=$this->_tpl_vars['application']->date_received)) ? $this->_run_mod_handler('escape', true, $_tmp, 'html') : smarty_modifier_escape($_tmp, 'html')); ?>
</date_received>            
            </application>
        <?php endforeach; endif; unset($_from); ?>
    </applications>
    
</planning>