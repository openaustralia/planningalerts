#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:cgi);
use DateTime;
use DateTime::Format::DateParse;
use HTML::TreeBuilder;
use LWP::UserAgent;
use XML::Writer;

# The master URL for the Broxbourne planning search
our $SearchURL = "http://www2.broxbourne.gov.uk/planningsearch/webform1.aspx";

# We're a CGI script...
my $query = CGI->new();

# Get the date as an offset from 2000-01-01
my $epoch = DateTime->new(year => 2000, month => 1, day => 1);
my $querydate = DateTime->new(year => $query->param("year"),
                              month => $query->param("month"),
                              day => $query->param("day"));
$querydate = $querydate->delta_days($epoch)->delta_days;

# Construct an LWP user agent
our $UA = LWP::UserAgent->new(env_proxy => 1);

# Post the URL to get an initial blank form
my $state = get_state(do_post());

# Post each date in turn to build up the state - you can thank
# Microsoft and ASP.NET for the horrible way we have to do this
# by posting each argument in turn to build up the state
$state = get_state(do_post_back($state, 'DateSelector1$Calendar1', $querydate));
$state = get_state(do_post_back($state, 'DateSelector2$Calendar1', $querydate));

# Create an XML output stream
my $Writer = XML::Writer->new(DATA_MODE => 1);

# Output the XML header data
$Writer->xmlDecl("UTF-8");
$Writer->startTag("planning");
$Writer->dataElement("authority_name", "Borough of Broxbourne");
$Writer->dataElement("authority_short_name", "Broxbourne");
$Writer->startTag("applications");

# Get the arguments for the search...
my $args = {
    "Srch" => "rb1",
    "__VIEWSTATE" => $state,
    "btnSearch" => "Search",
    "tbReference" => "",
    "tbRef2" => ""
};

# ...and then (at last) we can do the search!
my $page = do_post($args);

# Loop processing pages of results
while ($page)
{
    my $table = $page->look_down("_tag" => "table", "id" => "DataGrid1");

    # Remember the state
    $state = get_state($page);

    # Clear the page for now - this will be reinitialised if we
    # find another page of results to make us go round the loop
    # all over again
    undef $page;

    # Check that we found a table - searches that find no results
    # produce a page with no table in it
    if ($table)
    {
        # Process each row of the results
        foreach my $row ($table->look_down("_tag" => "tr"))
        {
            my @cells = $row->look_down("_tag" => "td");

            if ($cells[0]->look_down("_tag" => "input"))
            {
                my $reference = $cells[1]->as_trimmed_text;
                my $date = $cells[2]->as_trimmed_text;
                my $address = $cells[3]->as_trimmed_text;
                my $description = $cells[4]->as_trimmed_text;
                my $postcode;

                if ($address =~ /\s+([A-Z]+\d+\s+\d+[A-Z]+)$/)
                {
                    $postcode = $1;
                }

                $Writer->startTag("application");
                $Writer->dataElement("council_reference", $reference);
                $Writer->dataElement("address", $address);
                $Writer->dataElement("postcode", $postcode);
                $Writer->dataElement("description", $description);
                $Writer->dataElement("date_received", $date);
                $Writer->endTag("application");
            }
            elsif ($cells[0]->attr("colspan") && $cells[0]->attr("colspan") eq "5")
            {
                foreach my $link ($cells[0]->look_down("_tag" => "a"))
                {
                    if ($link->as_trimmed_text eq ">" &&
                        $link->attr("href") =~ /^javascript:__doPostBack\('([^\']*)','([^\']*)'\)$/)
                    {
                        $page = do_post_back($state, $1, $2);
                    }
                }
            }
        }
    }
}

# Finish off XML output
$Writer->endTag("applications");
$Writer->endTag("planning");
$Writer->end();

exit 0;

# Extract the state from a page so we can repost it
sub get_state
{
    my $page = shift;
    my $viewstate = $page->look_down("_tag" => "input", "name" => "__VIEWSTATE");

    return $viewstate->attr("value");
}

# Fake up what the doPostBack javascript function in the page does...
sub do_post_back
{
    my $state = shift;
    my $target = shift;
    my $argument = shift;

    $target =~ s/\$/:/g;

    my $args = {
        "__EVENTTARGET" => $target,
        "__EVENTARGUMENT" => $argument,
        "__VIEWSTATE" => $state
    };

    return do_post($args);
}

# Post to the planning search page
sub do_post
{
    my $response = $UA->post($SearchURL, @_);

    die $response->status_line unless $response->is_success;

    return HTML::TreeBuilder->new_from_content($response->content);
}
