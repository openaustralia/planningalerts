{foreach name="applications" from="$applications" item="application"}
{$application->address|upper} {$application->postcode|upper}  ({$application->council_reference|upper})

{$application->description}

MORE INFORMATION: {$application->info_tinyurl}
MAP: {$application->map_url}
WHAT DO YOU THINK?: {$application->comment_tinyurl}

=============================

{/foreach}

------------------------------------------------------------

PlanningAlerts.com is a free service run by volunteers.

You can subscribe to a geoRSS feed of applications for {$alert_postcode|upper} here: {$base_url}/api.php?postcode={$alert_postcode}&area_size={$alert_area_size}

To stop receiving these emails click here: {$base_url}/unsubscribe.php?cid={$confirm_id}