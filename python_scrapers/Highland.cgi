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
  <authority_name>Highland Council</authority_name>
  <authority_short_name>Highland</authority_short_name>
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
# $tree->parse_file('weekly-planning-bw-lists.htm');
$tree->parse(decode_utf8(get('http://www.highland.gov.uk/yourenvironment/planning/planningapplications/weekly-planning-bw-lists.htm') or die "couldn't fetch index page"));
$tree->eof;

my $monthyear_re = strftime('%B[ \xa0]%Y', 0, 0, 0, 1, $month-1, $year-1900);

my ($month_h2) = $tree->look_down(
	"_tag", "h2",
	sub {  $_[0]->as_text =~ /$monthyear_re/ }
);
$month_h2 or no_results($year, $month, $day, "Cannot find month header");

my $month_list = $month_h2->right;

my $day_re = strftime('Planning Applications (?:[A-Za-z0-9 ]*?to )?%b[a-z]* ?%e[a-z]', 0, 0, 0, $day, $month-1, $year-1900);

my ($day_link) = $month_list->look_down(
	"_tag", "a",
	sub {  $_[0]->as_text =~ /$day_re/ }
);
$day_link or no_results($year, $month, $day, "Cannot find day link");

my $day_absurl = "http://www.highland.gov.uk".$day_link->attr('href');

my ($fh, $filename) = tempfile(SUFFIX => ".pdf");
print $fh get($day_absurl);
close($fh);

print "Content-type: text/xml\n\n";
system "./Highland.pl", $filename, $day_absurl and die "system failed: $|";

unlink $filename or die "cannot unlink temporary file $filename: $!";
