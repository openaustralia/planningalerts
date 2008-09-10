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
  <authority_name>North Ayrshire Council</authority_name>
  <authority_short_name>North Ayrshire</authority_short_name>
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
$tree->parse(decode_utf8(get('http://www.north-ayrshire.gov.uk/na/Home.nsf/OtherMenuPage?ReadForm&MenuType=Environment-Planning&DocDisplay=NoDoc&CatLevel=2||') or die "couldn't fetch index page"));
$tree->eof;

my $re = strftime("Planning Applications Received week ending 0?$day %B %Y", 0, 0, 0, $day, $month-1, $year-1900);

my ($day_link) = $tree->look_down(
	"_tag", "a",
	sub {  $_[0]->as_text =~ /$re/i }
);
$day_link or no_results($year, $month, $day, "Cannot find day link");

my $day_absurl = 'http://www.north-ayrshire.gov.uk'.$day_link->attr('href');

my $day_tree = HTML::TreeBuilder->new;
$day_tree->parse(decode_utf8(get($day_absurl) or die "couldn't fetch day page"));
$day_tree->eof;

my ($pdf_img) = $day_tree->look_down(
	"_tag", "img",
	"alt", qr/\.pdf$/i
);
$pdf_img or die "couldn't find pdf image on day page";
my $pdf_link = $pdf_img->parent;
$pdf_link or die "couldn't find pdf link on day page";

my $pdf_absurl = 'http://www.north-ayrshire.gov.uk'.$pdf_link->attr('href');

my ($fh, $filename) = tempfile(SUFFIX => ".pdf");
print $fh get($pdf_absurl);
close($fh);

print "Content-type: text/xml\n\n";
system "./NorthAyrshire.pl", $filename, $pdf_absurl and die "system failed: $|";

unlink $filename or die "cannot unlink temporary file $filename: $!";
