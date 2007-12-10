#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:cgi);
use HTML::TreeBuilder;
use LWP::UserAgent;
use XML::Writer;

# Month names
our %Months = ( 1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr",
                5 => "May", 5 => "Jun", 7 => "Jul", 8 => "Aug",
                9 => "Sep", 10 => "Oct", 11 => "Nov", 12 => "Dec" );

# The master URLs for the Enfield planning search
our $StartURL = "http://www.southsomerset.gov.uk/index.jsp?articleid=1925&page_name=startsearch";
our $SearchURL = "http://www.southsomerset.gov.uk/index.jsp?articleid=1925&page_name=searchresults";

# We're a CGI script...
my $query = CGI->new();

# Get the date to fetch
my $date = $query->param("day") . "-" . $Months{$query->param("month")} . "-" . $query->param("year");

# Construct an LWP user agent
our $UA = LWP::UserAgent->new(env_proxy => 1, cookie_jar => {});

# Post acceptance of terms and conditions to get a cookie
do_post($StartURL, {"acceptTC" => "on"});

# Do the search
my $page = do_post($SearchURL,
                   {"startdate" => "12-Nov-2007", #$date,
                    "enddate" => $date,
                    "datesearch" => "applications",
                    "timeframe" => "yearonly",
                    "btnsubmit" => "search",
                    "address" => "",
                    "area" => "",
                    "caseno" => "",
                    "decision" => "",
                    "location" => "",
                    "parish" => "",
                    "postcode" => "",
                    "recentweeks" => "",
                    "ward" => ""});

# Output an HTTP response header
print $query->header(-type  => "text/xml");

# Create an XML output stream
my $Writer = XML::Writer->new(DATA_MODE => 1);

# Output the XML header data
$Writer->xmlDecl("UTF-8");
$Writer->startTag("planning");
$Writer->dataElement("authority_name", "South Somerset District Council");
$Writer->dataElement("authority_short_name", "South Somerset");
$Writer->startTag("applications");

# Output any applications on the first page
output_applications($page);

# Loop over any additional results pages
while (my $link = $page->look_down("_tag" => "a", sub { $_[0]->as_text eq "Next Page" }))
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
    my $reference;
    my $address;
    my $postcode;
    my $description;
    my $date_received;
    my $info_url;

    # Find the result table
    my $table = $page->look_down("_tag" => "div", "class" => "mainText")->look_down("_tag" => "table");

    # Process each row of the results
    foreach my $row ($table->look_down("_tag" => "tr"))
    {
        my @cells = $row->look_down("_tag" => "td");

        if (@cells == 1 && $cells[0]->look_down("_tag" => "hr"))
        {
            if (defined($reference))
            {
                $Writer->startTag("application");
                $Writer->dataElement("council_reference", $reference);
                $Writer->dataElement("address", $address);
                $Writer->dataElement("postcode", $postcode);
                $Writer->dataElement("description", $description);
                $Writer->dataElement("info_url", $info_url);
                $Writer->dataElement("date_received", $date_received);
                $Writer->endTag("application");
            }

            undef $reference;
            undef $address;
            undef $postcode;
            undef $description;
            undef $date_received;
            undef $info_url
        }
        elsif (@cells == 1 && defined($reference))
        {
            $description = $cells[0]->as_trimmed_text;

            $description =~ s/^Proposal:\s*//;
        }
        elsif (@cells == 5 && $cells[0]->as_trimmed_text =~ /^\d+/)
        {
            $reference = $cells[0]->as_trimmed_text;
            $date_received = $cells[1]->as_trimmed_text;
            $address = $cells[2]->as_trimmed_text;
            $info_url = URI->new_abs($cells[4]->look_down("_tag" => "a")->attr("href"), $SearchURL);

            if ($address =~ /\s+([A-Z]+\d+\s+\d+[A-Z]+)$/)
            {
                $postcode = $1;
            }
        }
    }

    return;
}
