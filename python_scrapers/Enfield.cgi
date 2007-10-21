#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:cgi);
use HTML::TreeBuilder;
use LWP::UserAgent;
use XML::Writer;


# The master URLs for the Enfield planning search
our $SearchURL = "http://forms.enfield.gov.uk/swiftlg/apas/run/WPHAPPCRITERIA";
our $InfoURL = "http://forms.enfield.gov.uk/swiftlg/apas/run/WPHAPPDETAIL.DisplayUrl?theApnID=";

# We're a CGI script...
my $query = CGI->new();

# Get the date to fetch
my $date = $query->param("day") . "/" . $query->param("month") . "/" . $query->param("year");

# Construct an LWP user agent
our $UA = LWP::UserAgent->new(env_proxy => 1);

# Do the search
my $page = do_post($SearchURL,
                   {"REGFROMDATE.MAINBODY.WPACIS.1." => $date,
                    "REGTODATE.MAINBODY.WPACIS.1." => $date,
                    "SEARCHBUTTON.MAINBODY.WPACIS.1." => "Search"});

# Output an HTTP response header
print $query->header(-type  => "text/xml");

# Create an XML output stream
my $Writer = XML::Writer->new(DATA_MODE => 1);

# Output the XML header data
$Writer->xmlDecl("UTF-8");
$Writer->startTag("planning");
$Writer->dataElement("authority_name", "Enfield Council");
$Writer->dataElement("authority_short_name", "Enfield");
$Writer->startTag("applications");

# Output any applications on the first page
output_applications($page);

# Loop over any additional results pages
foreach my $link ($page->look_down("_tag" => "a", "href" => qr/^WPHAPPSEARCHRES\.displayResultsURL/))
{
    # Fetch this page...
    $page = do_get(URI->new_abs($link->attr("href"), $SearchURL));

    # ...and output the applications from it
    output_applications($page);
}

# Finish off XML output
$Writer->endTag("applications");
$Writer->endTag("planning");
$Writer->end();

exit 0;

# Make a GET request
sub do_get
{
    my $response = $UA->get(@_);

    die $response->status_line unless $response->is_success;

    return HTML::TreeBuilder->new_from_content($response->content);
}

# Make a POST request
sub do_post
{
    my $response = $UA->post(@_);

    die $response->status_line unless $response->is_success;

    return HTML::TreeBuilder->new_from_content($response->content);
}

# Output applications from a results page
sub output_applications
{
    my $page = shift;

    # Find the result table
    my $table = $page->look_down("_tag" => "table", "class" => "apas_tbl");

    # Process each row of the results
    foreach my $row ($table->look_down("_tag" => "tr"))
    {
        my @cells = $row->look_down("_tag" => "td");

        if (@cells >= 3)
        {
            my $reference = $cells[0]->as_trimmed_text;
            my $description = $cells[1]->as_trimmed_text;
            my $address = $cells[2]->as_trimmed_text;
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
