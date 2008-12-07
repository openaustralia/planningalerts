{include file="header.tpl"}
    <form action="{$form_action}" method="post">
        <fieldset>
            <input type="hidden" name="_is_postback" value="1" />
        </fieldset>
        <div class="attention">
            <h3>Thanks, your alert has been activated</h3>
            <div class="ad">
                
                <h4>Find out even more about your local area using StreetWire</h4>
                <p>
                    StreetWire is like PlanningAlerts for everything. Including Licensing Applications, 
                    local news, crime and missing animals.
                    <br/>
                    <a href="http://www.streetwire.org">Visit StreetWire</a>
                </p>
                
            </div>
            <p>
                You will now receive email alerts for any planning applications we find near <strong>{$postcode|upper}</strong> (within approximately {$alert_area_size}m). If this alert doesn't cover everywhere you are interested in <span class="highlight"><a href="/">you can sign up for multiple alerts</a></span>
            </p>

            <!--
                <p>
                    If you are interested in discussing local issues with your MP and other local people you can also join <a href="http://www.hearfromyourmp.com">HearFromYourMP.com</a>! 
                </p>
            -->
            
        </div>
    </form>
{include file="footer.tpl"}