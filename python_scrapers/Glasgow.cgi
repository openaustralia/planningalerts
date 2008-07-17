#!/usr/bin/perl -w

use strict;

use LWP::Simple;
use File::Temp qw(tempfile);
use POSIX;
use CGI;

my $cgi = new CGI;

my $year = $cgi->param("year");
my $month = $cgi->param("month");
my $day = $cgi->param("day");

unless (defined $year && defined $month && defined $day) {
	print <<ERROR;
Content-type: text/plain

Need year, month, day parameters
ERROR
	exit 0;
}

my $html = get('http://www.glasgow.gov.uk/en/Business/Planning_Development/DevelopmentControl/Sitehistorysearches/');

my $date = sprintf("%02d/%02d/%02d", $day, $month, $year % 100);

# quick and dirty
my ($url) = ($html =~ /href="(\/[^"]*\.pdf)[^<]*[0-9]{2}\/[0-9]{2}\/[0-9]{2} - $date/);
unless (defined $url) {
	print <<NIL;
Content-type: text/xml

<?xml version="1.0" encoding="UTF-8"?>
<planning>
  <authority_name>Glasgow City Council</authority_name>
  <authority_short_name>Glasgow</authority_short_name>
  <applications>
  </applications>
</planning>
NIL
	exit 0;
}
my $absurl = "http://www.glasgow.gov.uk$url";

my ($fh, $filename) = tempfile(SUFFIX => ".pdf");
print $fh get($absurl);
close($fh);

print "Content-type: text/xml\n\n";
system "./Glasgow.pl", $filename, $absurl;

unlink $filename;
