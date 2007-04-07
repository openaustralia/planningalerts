<?php /* Smarty version 2.6.16, created on 2007-04-05 19:16:12
         compiled from about.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<p>You'd probably know if your next door neighbour was going to knock their house down (you'd get a letter through the door telling you they had applied for planning permission and asking you what you thought about it). But you probably never find out if the old cinema or pub 5 streets away is going to be converted into luxury flats until <a href="http://www.bbc.co.uk/cult/hitchhikers/gallery/tv/fordprosser.shtml">the bulldozers turned up</a>.</p>
<p>
    PlanningAlerts.com is a free service built by <a href="http://www.memespring.co.uk">Richard Pope</a>, <a href="http://brainoff.com">Mikel Maron</a>, Sam Smith and Duncan Parkes. The site is kindly hosted by  <a href="http://www.mysociety.org">mySociety.org</a>. It searches as many local authority planning websites as it can find and emails you details of applications near you. The aim of this to enable shared scrutiny of what is being built (and <a href="http://www.urban75.net/vbulletin/showthread.php?t=154006" title="Death of the Queen">knocked down</a>) in peoples communities.
</p>

<h3 id="authorities">Planning authorities currently covered by the service</h3>
<p><small><span class="highlight">New authorities are being added all the time, so if your local authority isn't listed below <a href="/">sign up any way</a> and you'll start receiving alerts once it has been included</span>.</small></p>

<ul class="nobullets">
    
    <?php $_from = ($this->_tpl_vars['authorities']); if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }$this->_foreach['authorities'] = array('total' => count($_from), 'iteration' => 0);
if ($this->_foreach['authorities']['total'] > 0):
    foreach ($_from as $this->_tpl_vars['authority']):
        $this->_foreach['authorities']['iteration']++;
?>
        <li><?php echo $this->_tpl_vars['authority']; ?>
</li>
    <?php endforeach; endif; unset($_from); ?>
    
</ul>

<p>If you are a programmer and would like to write a scraper for your local authority, or work for a local authority and would like to make your data available, <a href="/getinvolved.php">find out how you can get involved</a>.</p>

<h3 id="contact">Contact</h3>
<p>
   You can get in touch at <a href="#">team@planningalerts.com</a>
</p>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>