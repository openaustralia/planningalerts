<?xml version="1.0" encoding="UTF-8"?>
<planning>
    <authority_name>
        {$authority_name|escape:html}
    </authority_name>
    <authority_short_name>
        {$authority_short_name|escape:html}
    </authority_short_name>
    <applications>
        {foreach name="applications" from="$applications" item="application"}
            <application>
                <council_reference>{$application->council_reference|escape:html}</council_reference>
                <address>{$application->address|escape:html}</address>
                <postcode>{$application->postcode|escape:html}</postcode>
                <description>{$application->description|escape:html}</description>
                <info_url>{$application->info_url|escape:html}</info_url>
                <comment_url>{$application->comment_url|escape:html}</comment_url>
                <date_received>{$application->date_received|escape:html}</date_received>            
            </application>
        {/foreach}
    </applications>
    
</planning>