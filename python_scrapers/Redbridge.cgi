#!/usr/bin/perl -w

use strict;
use HTML::TreeBuilder;
use File::Temp qw(tempfile);
use LWP::Simple;
use POSIX;
use Encode;
use CGI;
use CGI::Carp;

sub sanity_check {
	my ($var) = @_;
	defined $var or return 0;
	$var =~ /^[0-9]+$/ or return 0;
	return 1;
}

sub no_results {
	my ($y, $m, $d, $reason) = @_;
	print <<NIL;
Content-type: text/xml

<?xml version="1.0" encoding="UTF-8"?>
<planning>
  <authority_name>London Borough of Redbridge</authority_name>
  <authority_short_name>Redbridge</authority_short_name>
  <applications>
  </applications>
</planning>
NIL
	die "$y/$m/$d failed: $reason\n";
}

my $cgi = new CGI;

my $year = $cgi->param("year");
my $month = $cgi->param("month");
my $day = $cgi->param("day");

unless (sanity_check($year) && sanity_check($month) && sanity_check($day)) {
	print <<ERROR;
Content-type: text/plain

Need year, month, day parameters
ERROR
	exit 0;
}

my $tree = HTML::TreeBuilder->new;
$tree->parse(decode_utf8(get('http://www.redbridge.gov.uk/cms/environment__planning/planning_and_regeneration/planning_dc.aspx') or die "couldn't fetch index page"));
$tree->eof;

my $re = sprintf('Planning Applications Received %d', $year);

my ($year_link) = $tree->look_down(
	"_tag", "a",
	sub {  $_[0]->as_text =~ /$re/i }
);
$year_link or no_results($year, $month, $day, "Cannot find year link");

my $year_absurl = 'http://www.redbridge.gov.uk'.$year_link->attr('href');

my $year_tree = HTML::TreeBuilder->new;
$year_tree->parse(decode_utf8(get($year_absurl) or die "couldn't fetch day page"));
$year_tree->eof;

my $day_re = strftime("Received 0?$day\[a-z]* %B %Y", 0, 0, 0, $day, $month-1, $year-1900);
$day_re =~ s/ +/\\s+/g;
my ($pdf_link) = $year_tree->look_down(
	"_tag", "a",
	sub { $_[0]->as_text =~ /$day_re/i }
);
$pdf_link or no_results($year, $month, $day, "Cannot find day link");

my $pdf_absurl = 'http://www.redbridge.gov.uk/cms/'.$pdf_link->attr('href');

my ($fh, $filename) = tempfile(SUFFIX => ".pdf");
print $fh get($pdf_absurl);
close($fh);

print "Content-type: text/xml\n\n";
system "./Redbridge.pl", $filename, $pdf_absurl and die "system failed: $|";

unlink $filename or die "cannot unlink temporary file $filename: $!";
