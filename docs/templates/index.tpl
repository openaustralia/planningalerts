{include file="header.tpl"}
<form action="{$form_action}" method="post">
    <fieldset>
        <input type="hidden" name="_is_postback" value="1" />
    </fieldset>

    <ul id="ulSignup" class="form nobullets">
        <li id="liEmail">
            <label for="txtEmail"><span class="number">1</span> Enter your email address</label>
            <input type="text"  class="textbox {if $email_warn == true}error{/if}" id="txtEmail" name="txtEmail" value="{$email}" />
        </li>
        <li id="liPostcode">
            <label for="txtPostcode"><span class="number">2</span> Enter a postcode</label>
            <input type="text" class="textbox  {if $postcode_warn == true}error{/if}" id="txtPostcode" name="txtPostcode" value="{$postcode}" />
            <small>e.g. SW9 8JX</small>
        </li>
        <li id="liAlertArea">
            <p id="pAlertArea"><span class="number">3</span> Choose what size area would you like to receive alerts for</p>
            <fieldset>
                <ul id="ulAlertArea" class="form nobullets">
                    <li>
                        <input type="radio" id="radAlertAreaSize_street" name="radAlertAreaSize" value="s" {if $alert_area_size == s}checked="checked"{/if} />
                        <label for="radAlertAreaSize_street">My street (approximately {$small_zone_size} m)</label> <small><a href="javascript:previewMap('s');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_neihgbourhood" name="radAlertAreaSize" value="m" {if $alert_area_size == m}checked="checked"{/if} />                                    
                        <label for="radAlertAreaSize_neihgbourhood">My neighbourhood  (approximately {$medium_zone_size} m)</label> <small><a href="javascript:previewMap('m');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_town" name="radAlertAreaSize" value="l" {if $alert_area_size == l}checked="checked"{/if} />                                    
                        <label for="radAlertAreaSize_town">Wider area  (approximately {$large_zone_size} m)</label> <small><a href="javascript:previewMap('l');">view on a map (new window)</a></small>                                
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
        <li><em>July 2007</em>Added 21 councils inc. Lewisham, New Forest National Park and Edinburgh </li>        
        <li><em>April 2007</em>Added 50 more councils.<li>  
        <li><em>March 2007</em> Added an API and a few more councils (inc. Islington and Hackney)</li>
        <li><em>February 2007</em> Added loads more councils (inc. Camden and Tower Hamlets)</li>
        <li><em>December 2006</em> beta launch</li>
    </ul>   
</div>

{include file="footer.tpl"}