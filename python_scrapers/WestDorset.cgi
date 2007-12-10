#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:cgi);
use HTML::TreeBuilder;
use LWP::UserAgent;
use XML::Writer;


# The master URLs for the West Dorset planning search
our $SearchURL = "http://webapps.westdorset-dc.gov.uk/planningapplications/pages/applicationsearch.aspx";
our $InfoURL = "http://webapps.westdorset-dc.gov.uk/planningapplications/pages/ApplicationDetails.aspx?Authority=West%20Dorset%20District%20Council&Application=";

# We're a CGI script...
my $query = CGI->new();

# Get the date to fetch
my $date = $query->param("day") . "/" . $query->param("month") . "/" . $query->param("year");

# Construct an LWP user agent
our $UA = LWP::UserAgent->new(env_proxy => 1);

# Post the URL to get an initial blank form
my $page = do_post();

# Do the search
$page = do_post($page,
                {"DetailedSearch\$TextBox_DateRaisedFrom" => $date,
                 "DetailedSearch\$TextBox_DateRaisedTo" => $date,
                 "DetailedSearch\$Button_DetailedSearch" => "Search"});

# Output an HTTP response header
print $query->header(-type  => "text/xml");

# Create an XML output stream
my $Writer = XML::Writer->new(DATA_MODE => 1);

# Output the XML header data
$Writer->xmlDecl("UTF-8");
$Writer->startTag("planning");
$Writer->dataElement("authority_name", "West Dorset District Council");
$Writer->dataElement("authority_short_name", "West Dorset");
$Writer->startTag("applications");

# Output any applications on the first page
output_applications($page);

# Loop over any additional results pages
while (my $link = $page->look_down("_tag" => "a", "id" => "MatchingApplications_ResultsNavigationTop_LinkButton_Next"))
{
    # Fetch this page...
    $page = do_post_back($page, 'MatchingApplications$ResultsNavigationTop$LinkButton_Next', '');

    # ...and output the applications from it
    output_applications($page);
}

# Finish off XML output
$Writer->endTag("applications");
$Writer->endTag("planning");
$Writer->end();

exit 0;

# Fake up what the doPostBack javascript function in the page does...
sub do_post_back
{
    my $previous = shift;
    my $target = shift;
    my $argument = shift;

    $target =~ s/\$/:/g;

    my $args = {
        "__EVENTTARGET" => $target,
        "__EVENTARGUMENT" => $argument,
    };

    return do_post($previous, $args);
}

# Make a POST request
sub do_post
{
    my $previous = shift;
    my $args = shift || {};

    if (defined($previous))
    {
        my $viewstate = $previous->look_down("_tag" => "input", "name" => "__VIEWSTATE");
        my $eventvalidation = $previous->look_down("_tag" => "input", "name" => "__EVENTVALIDATION");

        $args->{"__VIEWSTATE"} = $viewstate->attr("value");
        $args->{"__EVENTVALIDATION"} = $eventvalidation->attr("value");
    }

    my $response = $UA->post($SearchURL, $args);

    die $response->status_line unless $response->is_success;

    return HTML::TreeBuilder->new_from_content($response->content);
}

# Output applications from a results page
sub output_applications
{
    my $page = shift;

    # Find the result table
    my $table = $page->look_down("_tag" => "table", "class" => "searchresults");

    # No results means no results table
    if (defined($table))
    {
        # Process each row of the results
        foreach my $row ($table->look_down("_tag" => "tr"))
        {
            my $class = $row->attr("class") || "";

            next if $class eq "searchresultsheader";

            my @cells = $row->look_down("_tag" => "td");
            my $reference = $cells[0]->as_trimmed_text;
            my $date = $cells[1]->as_trimmed_text;
            my $address = $cells[2]->as_trimmed_text;
            my $description = $cells[3]->as_trimmed_text;
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
            $Writer->dataElement("info_url", $InfoURL . $reference);
            $Writer->dataElement("date_received", $date);
            $Writer->endTag("application");
        }
    }

    return;
}
