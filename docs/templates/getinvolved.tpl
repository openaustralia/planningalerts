{include file="header.tpl"}

    <p>PlanningAlerts.org.au is run by a charity, the OpenAustralia Foundation, and relies on the support of volunteers. If you would like to get involved we'd love to hear from you:</p>

    <h3>I am a programmer and want to add my local planning authority</h3>
    <p>
        You can help by writing a <a href="http://en.wikipedia.org/wiki/Screen_scraping">screen scraper</a> for your local planning authority that we can import into planningalerts.org.au. There are only 2 criteria for the screen scraper:
    </p>
    <ol>
        <li>That it can output data in the following format: <a href="{$base_url}/brisbane.xml">{$base_url}/brisbane.xml</a></li>
        <li>That it can accept a query sting in the format day=X&amp;month=Y&amp;year=Z</li>
    </ol>
    <p>
       Other than that it's up to you. It can be in any language. You can host them yourself or we can host it for you.
    </p>
    <p><span class="highlight">Please go ahead and <a href="http://github.com/openaustralia/planningalerts-app">grab the code for this site</a> and <a href="http://tickets.openaustralia.org/browse/PA">view some development tickets</a> or join the <a href="http://groups.google.com/group/openaustralia-dev">OpenAustralia Community mailing list</a>.</span>
    </p>
    <h3>I work for a local council or planning authority and would like to make our data available</h3>
    <p>
        The most important thing you can do is publish your data in a simple format that is freely available on the internet. Something <a href="{$base_url}/brisbane.xml">like this</a> is good but we can work with most formats. Please <a href="/about.php#contact">get in touch</a> if you would like to discuss how you can help.
    </p>
    
    
{include file="footer.tpl"}
