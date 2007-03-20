<?php /* Smarty version 2.6.16, created on 2006-12-28 14:35:03
         compiled from unsubscribed.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'upper', 'unsubscribed.tpl', 5, false),)), $this); ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
    <div class="attention">
        <h3>You have been unsubscribed</h3>
        <p>
            You will no longer receive email alerts for any planning applications we find near <strong><?php echo ((is_array($_tmp=$this->_tpl_vars['postcode'])) ? $this->_run_mod_handler('upper', true, $_tmp) : smarty_modifier_upper($_tmp)); ?>
</strong> (within approximately <?php echo $this->_tpl_vars['alert_area_size']; ?>
m).
        </p>
        <p>
            If you have unsubscribed because you were getting too many emails, you could always create a new alert for a smaller area?
        </p>
    </div>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>