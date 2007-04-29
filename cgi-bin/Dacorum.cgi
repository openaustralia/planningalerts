#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:cgi);
use HTML::TreeBuilder;
use LWP::UserAgent;
use XML::Writer;

# The master URLs for the Dacorum planning search
our $SearchURL = "http://www.dacorum.gov.uk/default.aspx?page=1495";
our $InfoURL = "http://www.dacorum.gov.uk/Default.aspx?page=1497&ID=";
our $CommentURL = "http://www.dacorum.gov.uk/Default.aspx?page=2847&ID=";

# We're a CGI script...
my $query = CGI->new();

# Construct an LWP user agent
our $UA = LWP::UserAgent->new(env_proxy => 1,
                              cookie_jar => {},
                              requests_redirectable => [ 'GET', 'HEAD', 'POST' ]);

# Post the URL to get an initial blank form
my $state = get_state(do_post());

# Do the search
my $page = do_post({"__VIEWSTATE" => $state,
                    "Template:_ctl10:_ctl0:btnSearch" => "Search",
                    "Template:_ctl10:_ctl0:tbRegistrationFromDay" => $query->param("day"),
                    "Template:_ctl10:_ctl0:tbRegistrationFromMon" => $query->param("month"),
                    "Template:_ctl10:_ctl0:tbRegistrationFromYear" => $query->param("year"),
                    "Template:_ctl10:_ctl0:tbRegistrationToDay" => $query->param("day"),
                    "Template:_ctl10:_ctl0:tbRegistrationToMon" => $query->param("month"),
                    "Template:_ctl10:_ctl0:tbRegistrationToYear" => $query->param("year")});

# Output an HTTP response header
print $query->header(-type  => "text/xml");

# Create an XML output stream
my $Writer = XML::Writer->new(DATA_MODE => 1);

# Output the XML header data
$Writer->xmlDecl("UTF-8");
$Writer->startTag("planning");
$Writer->dataElement("authority_name", "Dacorum Borough Council");
$Writer->dataElement("authority_short_name", "Dacorum");
$Writer->startTag("applications");

# Find the result table
my $table = $page->look_down("_tag" => "table", "class" => "FormDataGrid");

# Process each row of the results
foreach my $row ($table->look_down("_tag" => "tr"))
{
    my @cells = $row->look_down("_tag" => "td");

    if ($cells[0]->attr("class") eq "FormGridDataItem" ||
        $cells[0]->attr("class") eq "FormGridAlternatingDataItem")
    {
        my $reference = $cells[0]->as_trimmed_text;
        my $address = $cells[1]->as_trimmed_text;
        my $description = $cells[2]->as_trimmed_text;
        my $date = $cells[3]->as_trimmed_text;
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
        $Writer->dataElement("comment_url", $CommentURL . $reference);
        $Writer->dataElement("date_received", $date);
        $Writer->endTag("application");
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

# Post to the planning search page
sub do_post
{
    my $response = $UA->post($SearchURL, @_);

    die $response->status_line unless $response->is_success;

    return HTML::TreeBuilder->new_from_content($response->content);
}
