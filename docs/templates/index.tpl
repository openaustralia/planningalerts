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
            <p id="pAlertArea"><span class="number">3</span>What size area would you like to receive alerts for?</p>
            <fieldset>
                <ul id="ulAlertArea" class="form nobullets">
                    <li>
                        <input type="radio" id="radAlertAreaSize_street" name="radAlertAreaSize" value="s" {if $alert_area_size == s}checked="checked"{/if} />
                        <label for="radAlertAreaSize_street">My street (about {$small_zone_size_in_words})</label> <small><a href="javascript:previewMap('{$small_zone_size}');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_neihgbourhood" name="radAlertAreaSize" value="m" {if $alert_area_size == m}checked="checked"{/if} />                                    
                        <label for="radAlertAreaSize_neihgbourhood">My neighbourhood  (about {$medium_zone_size_in_words})</label> <small><a href="javascript:previewMap('{$medium_zone_size}');">view on a map (new window)</a></small>
                    </li>
                    <li>
                        <input type="radio" id="radAlertAreaSize_town" name="radAlertAreaSize" value="l" {if $alert_area_size == l}checked="checked"{/if} />                                    
                        <label for="radAlertAreaSize_town">My suburb  (about {$large_zone_size_in_words})</label> <small><a href="javascript:previewMap('{$large_zone_size}');">view on a map (new window)</a></small>                                
                    </li>
                    <li>
                        <noscript><fieldset>Note: viewing the alert area on a map requires javascript</fieldset></noscript>
                    </li>
                </ul>
            </fieldset>
        </li>  
        <input type="submit" class="button" value="Create alert >>" />
        <p id="spnBeta">It's early days for this service so your local authority may not be included yet. Sign up
            anyway and you'll receive alerts as soon as they're available.</p>
    </ul>
</form>

{include file="footer.tpl"}