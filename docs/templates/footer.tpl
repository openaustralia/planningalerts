        </div>
        <div id="divFooter">
            <ul class="inline">
                <li><a href="/">Home</a></li>
                <li><a href="about.php">About</a></li>                
                <li><a href="about.php#contact">Contact</a></li>                
            </ul>
        </div>
    </div>
    {if $onloadscript !="" || $set_focus_control !=""}
		<script type="text/javascript" defer="defer">
			{if $set_focus_control !=""}setFocus('{$set_focus_control}');{/if}
			{if $onloadscript !=""} {$onloadscript}; {/if}
		</script>
	{/if}
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
    </script>
    <script type="text/javascript">
        _uacct = "UA-321882-8";
        urchinTracker();
    </script>
</body>
</html>
