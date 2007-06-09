<?php /* Smarty version 2.6.16, created on 2007-06-09 16:07:32
         compiled from confirm_email_text.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('block', 'textformat', 'confirm_email_text.tpl', 1, false),)), $this); ?>
<?php $this->_tag_stack[] = array('textformat', array('style' => 'email')); $_block_repeat=true;smarty_block_textformat($this->_tag_stack[count($this->_tag_stack)-1][1], null, $this, $_block_repeat);while ($_block_repeat) { ob_start(); ?>

Please click on the link below to confirm you want to receive email alerts for planning applications near <?php echo $this->_tpl_vars['postcode']; ?>
:

<?php echo $this->_tpl_vars['url']; ?>


If your email program does not let you click on this link, just copy and paste it into your web browser and hit return.

<?php $_block_content = ob_get_contents(); ob_end_clean(); $_block_repeat=false;echo smarty_block_textformat($this->_tag_stack[count($this->_tag_stack)-1][1], $_block_content, $this, $_block_repeat); }  array_pop($this->_tag_stack); ?>