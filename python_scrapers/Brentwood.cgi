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

my $html = get('http://www.brentwood-council.gov.uk/index.php?cid=573');

my $date = strftime("%d %B %Y", 0, 0, 0, $day, $month-1, $year-1900);

# quick and dirty
my ($url) = ($html =~ /(http:\/\/[^"]*\.pdf)[^<]*(<[^>]*>)*[^<]*$date/);
unless (defined $url) {
	print <<NIL;
Content-type: text/xml

<?xml version="1.0" encoding="UTF-8"?>
<planning>
  <authority_name>Brentwood Borough Council</authority_name>
  <authority_short_name>Brentwood</authority_short_name>
  <applications>
  </applications>
</planning>
NIL
	exit 0;
}

my $dmy = sprintf("%02d/%02d/%04d", $day, $month, $year);

my ($fh, $filename) = tempfile(SUFFIX => ".pdf");
print $fh get($url);
close($fh);

print "Content-type: text/xml\n\n";
system "./Brentwood.pl", $filename, $url, $dmy;

unlink $filename;
