        </div>
        <div id="divFooter">
            <ul class="inline">
                <li><a href="about.php#contact">Contact</a></li>  
                <li><a href="http://blog.openaustralia.org">Blog</a></li>
                <li><a href="http://twitter.com/planningalerts">Twitter</a></li>              
            </ul>
            <span id="oaf">An OpenAustralia Foundation Project</span>
            {*            
            <a id="aOpen" href="http://okd.okfn.org/" title="Data on this site is open"><span class="hide">Open Data</span></a>

            <a id="aHosted" href="http://www.mysociety.org" title="This website is hosted by mySociety"><span class="hide">Hosted by MySociety</span></a>
            *}
        </div>
    </div>
    {if $onloadscript !="" || $set_focus_control !=""}
    <script type="text/javascript" defer="defer">{if $set_focus_control !=""}setFocus('{$set_focus_control}');{/if}{if $onloadscript !=""}{$onloadscript};{/if}</script>
    {/if}
</body>
</html>
