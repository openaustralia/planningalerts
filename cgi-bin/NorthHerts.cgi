#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:cgi);
use HTML::TreeBuilder;
use LWP::UserAgent;
use XML::Writer;

# The master URLs for the North Hertfordshire planning search
our $SearchURL = "http://www.north-herts.gov.uk/dcdataonline/Pages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch";

# We're a CGI script...
my $query = CGI->new();

# Get the date to fetch
my $date = $query->param("day") . "/" . $query->param("month") . "/" . $query->param("year");

# Construct an LWP user agent
our $UA = LWP::UserAgent->new(env_proxy => 1);

# Fetch the search page
my $page = do_get($SearchURL);

# Find the form submission URL
my $form = $page->look_down("_tag" => "form", name => "frmSearch");
my $url = URI->new_abs($form->attr("action"), $SearchURL);

# Do the search
$page = do_post($url, {"regdate1" => $date, "regdate2" => $date});

# Output an HTTP response header
print $query->header(-type  => "text/xml");

# Create an XML output stream
my $Writer = XML::Writer->new(DATA_MODE => 1);

# Output the XML header data
$Writer->xmlDecl("UTF-8");
$Writer->startTag("planning");
$Writer->dataElement("authority_name", "North Hertfordshire District Council");
$Writer->dataElement("authority_short_name", "North Hertfordshire");
$Writer->startTag("applications");

# Process each table of the results
foreach my $table ($page->look_down("_tag" => "table", "class" => "results-table"))
{
    my @rows = map { $_->look_down("_tag" => "td") } $table->look_down("_tag" => "tr");
    my $reference = $rows[0]->as_trimmed_text;
    my $infourl = $rows[0]->look_down("_tag" => "a")->attr("href");
    my $date = $rows[1]->as_trimmed_text;
    my $address = $rows[3]->as_trimmed_text;
    my $description = $rows[4]->as_trimmed_text;
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
    $Writer->dataElement("info_url", $infourl);
    $Writer->dataElement("comment_url", "mailto:service\@north-herts.gov.uk?subject=Comment on Planning Application");
    $Writer->dataElement("date_received", $date);
    $Writer->endTag("application");
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
    my $response = $UA->post(@_, Content_Type => "form-data");

    die $response->status_line unless $response->is_success;

    return HTML::TreeBuilder->new_from_content($response->content);
}
