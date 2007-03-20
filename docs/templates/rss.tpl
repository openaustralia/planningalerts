<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:georss="http://georss.org/georss">
	<channel>
		<title>Search Results</title>
		<link></link>
		<description></description>
        {foreach name="applications" from="$applications" item="application"}
            <item>
                <guid>{$application->council_reference}</guid>
                <georss:featurename>{$application->address}</georss:featurename>
                <georss:point>{$application->lat} {$application->lon}</georss:point>
                <description>{$application->description}</description>
                <link>{$application->info_url}</link>
                <comments>{$application->comment_url}</comments>
                <pubDate>{$application->date_received}</pubDate>            
            </item>
        {/foreach}
    </channel>
</rss>
