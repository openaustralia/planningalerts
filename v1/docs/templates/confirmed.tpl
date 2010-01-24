{include file="header.tpl"}
    <form action="{$form_action}" method="post">
        <fieldset>
            <input type="hidden" name="_is_postback" value="1" />
        </fieldset>
        <div class="attention">
            <h3>Thanks, your alert has been activated</h3>
            <p>
                You will now receive email alerts for any planning applications we find near <strong>{$address}</strong> (within approximately {$area_size_meters}m). If this alert doesn't cover everywhere you are interested in <span class="highlight"><a href="/">you can sign up for multiple alerts</a></span>
            </p>
        </div>
    </form>
{include file="footer.tpl"}