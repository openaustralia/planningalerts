{include file="header.tpl"}
    <form action="{$form_action}" method="post">
        <fieldset>
            <input type="hidden" name="_is_postback" value="1" />
        </fieldset>
        <div class="attention">
            <h3>Thanks, your alert has been activated</h3>
            <p>
                You will now receive email alerts for any planning applications we find near <strong>{$postcode|upper}</strong> (within approximately {$alert_area_size}m). If this alert doesn't cover everywhere you are interested in <span class="highlight"><a href="/">you can sign up for multiple alerts</a></span>
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
{include file="footer.tpl"}