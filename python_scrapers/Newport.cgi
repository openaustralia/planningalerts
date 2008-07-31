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
  <authority_name>Newport City Council</authority_name>
  <authority_short_name>Newport</authority_short_name>
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
$tree->parse(decode_utf8(get('http://www.newport.gov.uk/_dc/index.cfm?fuseaction=planapps.applist') or die "couldn't fetch index page"));
$tree->eof;

my $re = sprintf('Lists?\s+for %02d/%02d/%04d', $day, $month, $year);

my ($day_p) = $tree->look_down(
	"_tag", "p",
	sub {  $_[0]->as_text =~ /$re/i }
);
$day_p or no_results($year, $month, $day, "Cannot find day paragraph");

my ($day_link) = $day_p->find_by_tag_name("a");
$day_link or no_results($year, $month, $day, "Cannot find day link");

my $day_absurl = $day_link->attr('href');

my ($fh, $filename) = tempfile(SUFFIX => ".pdf");
print $fh get($day_absurl);
close($fh);

print "Content-type: text/xml\n\n";
system "./Newport.pl", $filename, $day_absurl and die "system failed: $|";

unlink $filename or die "cannot unlink temporary file $filename: $!";
