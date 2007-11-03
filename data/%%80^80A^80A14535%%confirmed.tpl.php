<?php /* Smarty version 2.6.16, created on 2007-11-03 10:05:39
         compiled from confirmed.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'upper', 'confirmed.tpl', 9, false),)), $this); ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
    <form action="<?php echo $this->_tpl_vars['form_action']; ?>
" method="post">
        <fieldset>
            <input type="hidden" name="_is_postback" value="1" />
        </fieldset>
        <div class="attention">
            <h3>Thanks, your alert has been activated</h3>
            <p>
                You will now receive email alerts for any planning applications we find near <strong><?php echo ((is_array($_tmp=$this->_tpl_vars['postcode'])) ? $this->_run_mod_handler('upper', true, $_tmp) : smarty_modifier_upper($_tmp)); ?>
</strong> (within approximately <?php echo $this->_tpl_vars['alert_area_size']; ?>
m). If this alert doesn't cover everywhere you are interested in <span class="highlight"><a href="/">you can sign up for multiple alerts</a></span>
            </p>

            <!--
                <p>
                    If you are interested in discussing local issues with your MP and other local people you can also join <a href="http://www.hearfromyourmp.com">HearFromYourMP.com</a>! 
                </p>
            -->
            
            <div class="ad">
                
                <h4>Are you a member of a local community email group or forum?</h4>
                <p>
                    Help your neighbours find the group using by adding it to our sister site 
                    <a href="http://www.groupsnearyou.com/add/about/">GroupsNearYou.com</a>
                </p>
                
            </div>
        </div>
    </form>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>