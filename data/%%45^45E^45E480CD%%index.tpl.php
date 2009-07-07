<?php /* Smarty version 2.6.16, created on 2009-07-05 11:09:09
         compiled from index.tpl */ ?>
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

    <ul id="ulSignup" class="form nobullets">
        <li id="liEmail">
            <label for="txtEmail"><span class="number">1</span> Enter your email address</label>
            <input type="text"  class="textbox <?php if ($this->_tpl_vars['email_warn'] == true): ?>error<?php endif; ?>" id="txtEmail" name="txtEmail" value="<?php echo $this->_tpl_vars['email']; ?>
" />
        </li>
        <li id="liPostcode">
            <label for="txtPostcode"><span class="number">2</span> Enter a postcode</label>
            <input type="text" class="textbox  <?php if ($this->_tpl_vars['postcode_warn'] == true): ?>error<?php endif; ?>" id="txtPostcode" name="txtPostcode" value="<?php echo $this->_tpl_vars['postcode']; ?>
" />
            <small>e.g. SW9 8JX</small>
        </li>
        <li id="liAlertArea">
            <p id="pAlertArea"><span class="number">3</span> Choose what size area would you like to receive alerts for</p>
            <fieldset>
                <ul id="ulAlertArea" class="form nobullets">
                    <li>
                        <input type="radio" id="radAlertAreaSize_street" name="radAlertAreaSize" value="s" <?php if ($this->_tpl_vars['alert_area_size'] == s): ?>checked="checked"<?php endif; ?> />
                        <label for="radAlertAreaSize_street">My street (approximately <?php echo $this->_tpl_vars['small_zone_size']; ?>
 m)</label> <small><a href="javascript:previewMap('s');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_neihgbourhood" name="radAlertAreaSize" value="m" <?php if ($this->_tpl_vars['alert_area_size'] == m): ?>checked="checked"<?php endif; ?> />                                    
                        <label for="radAlertAreaSize_neihgbourhood">My neighbourhood  (approximately <?php echo $this->_tpl_vars['medium_zone_size']; ?>
 m)</label> <small><a href="javascript:previewMap('m');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_town" name="radAlertAreaSize" value="l" <?php if ($this->_tpl_vars['alert_area_size'] == l): ?>checked="checked"<?php endif; ?> />                                    
                        <label for="radAlertAreaSize_town">Wider area  (approximately <?php echo $this->_tpl_vars['large_zone_size']; ?>
 m)</label> <small><a href="javascript:previewMap('l');">view on a map (new window)</a></small>                                
                    </li>
                    <li>
                        <noscript><fieldset>Note: viewing the alert area on a map requires javascript</fieldset></noscript>
                    </li>
                </ul>
            </fieldset>
        </li>  
        <li id="liSignup">
            <input type="submit" class="button" value="Create alert >>" />
            <span id="spnBeta">This site is in Beta (test) mode, so all local authorities near you may not be included in alerts.</span>
        </li>              
    </ul>
</form>
<div id="divSiteUpdates">
    <h4>Recent site updates</h4>
    <ul class="nobullets">
        <li><em>May 2008</em>Now has 250 Local authorities covered</li>        
        <li><em>July 2007</em>Shortlisted for New Statesman New Media Award</li>        
        <li><em>July 2007</em>Added 21 councils inc. Lewisham, New Forest National Park and Edinburgh </li>        
        <li><em>April 2007</em>Added 50 more councils.<li>  
        <li><em>March 2007</em> Added an API and a few more councils (inc. Islington and Hackney)</li>
        <li><em>February 2007</em> Added loads more councils (inc. Camden and Tower Hamlets)</li>
        <li><em>December 2006</em> beta launch</li>
    </ul>   
</div>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>