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
        <li id="liAddress">
            <label for="txtAddress"><span class="number">2</span> Enter a street address</label>
            <input type="text" class="textbox  {if $address_warn == true}error{/if}" id="txtAddress" name="txtAddress" value="{$address}" />
            <small>e.g. 24 Bruce Road, Glenbrook, NSW 2773</small>
        </li>
        <li id="liAlertArea">
            <p id="pAlertArea"><span class="number">3</span> Choose what size area would you like to receive alerts for</p>
            <fieldset>
                <ul id="ulAlertArea" class="form nobullets">
                    <li>
                        <input type="radio" id="radAlertAreaSize_street" name="radAlertAreaSize" value="s" {if $alert_area_size == s}checked="checked"{/if} />
                        <label for="radAlertAreaSize_street">My street (approximately {$small_zone_size} m)</label> <small><a href="javascript:previewMap('{$small_zone_size}');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_neihgbourhood" name="radAlertAreaSize" value="m" {if $alert_area_size == m}checked="checked"{/if} />                                    
                        <label for="radAlertAreaSize_neihgbourhood">My neighbourhood  (approximately {$medium_zone_size} m)</label> <small><a href="javascript:previewMap('{$medium_zone_size}');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_town" name="radAlertAreaSize" value="l" {if $alert_area_size == l}checked="checked"{/if} />                                    
                        <label for="radAlertAreaSize_town">Wider area  (approximately {$large_zone_size} m)</label> <small><a href="javascript:previewMap('{$large_zone_size}');">view on a map (new window)</a></small>                                
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

{include file="footer.tpl"}