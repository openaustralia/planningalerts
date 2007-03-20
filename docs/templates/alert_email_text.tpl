{textformat style='email'}    

     	{foreach name="applications" from="$applications" item="application"}
     	    
     	    {$application->address} {$application->postcode}  ({$application->council_reference})

            {$application->description}

            View more information: {$application->info_tinyurl}
            
            View on a map (approximate): {$application->map_url}
            
            What do you think about this?: {$application->comment_tinyurl}

            =============================
            
     	{/foreach}
     	
     	
     	--------------------------------------
     	PlanningAlerts.com is a free service run by volunteers
     	To stop receiving these emails click here: {$base_url}/unsubscribe.php?cid={$confirm_id}

{/textformat}