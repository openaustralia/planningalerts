{foreach name="applications" from="$applications" item="application"}
{$application->address|upper} ({$application->council_reference|upper})

{$application->description}

MORE INFORMATION: {$application->info_tinyurl}
MAP: {$application->map_url}
WHAT DO YOU THINK?: {$application->comment_tinyurl}

=============================

{/foreach}

------------------------------------------------------------

PlanningAlerts.org.au is a free service run by the charity OpenAustralia Foundation.

You can subscribe to a geoRSS feed of applications for {$alert_postcode|upper} here: {$base_url}/api.php?address={$alert_address|escape:'url'}&area_size={$area_size_meters}

To stop receiving these emails click here: {$base_url}/unsubscribe.php?cid={$confirm_id}