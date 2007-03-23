<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:georss="http://georss.org/georss">
	<channel>
		<title>Search Results</title>
		<link>http://www.planningalerts.com/</link>
		<description></description>
        {foreach name="applications" from="$applications" item="application"}
            <item>
                <guid isPermaLink="false">{$application->council_reference}</guid>
                <georss:featurename>{$application->address}</georss:featurename>
                <georss:point>{$application->lat} {$application->lon}</georss:point>
                <description><![CDATA[{$application->description}]]></description>
                <link><![CDATA[{$application->info_url}]]></link>
                <comments><![CDATA[{$application->comment_url}]]></comments>
            </item>
        {/foreach}
    </channel>
</rss>
