<?php /* Smarty version 2.6.16, created on 2007-03-17 15:57:52
         compiled from footer.tpl */ ?>
        </div>
        <div id="divFooter">
            <ul class="inline">
                <li><a href="/">Home</a></li>
                <li><a href="about.php">About</a></li>                
                <li><a href="about.php#contact">Contact</a></li>                
            </ul>
        </div>
    </div>
    <?php if ($this->_tpl_vars['onloadscript'] != "" || $this->_tpl_vars['set_focus_control'] != ""): ?>
		<script type="text/javascript" defer="defer">
			<?php if ($this->_tpl_vars['set_focus_control'] != ""): ?>setFocus('<?php echo $this->_tpl_vars['set_focus_control']; ?>
');<?php endif; ?>
			<?php if ($this->_tpl_vars['onloadscript'] != ""): ?> <?php echo $this->_tpl_vars['onloadscript']; ?>
; <?php endif; ?>
		</script>
	<?php endif; ?>
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
    </script>
    <script type="text/javascript">
        _uacct = "UA-321882-8";
        urchinTracker();
    </script>
</body>
</html>