#!/usr/bin/perl -w

use strict;
use XML::Writer;

my $file = $ARGV[0];
my $info_url = $ARGV[1];

my $writer = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 2);

$writer->xmlDecl("UTF-8");

$writer->startTag("planning");
$writer->dataElement("authority_name", "Highland Council");
$writer->dataElement("authority_short_name", "Highland");
$writer->startTag("applications");

open (my $fh, '-|', "pdftotext", "-layout", $file, "-") or die "open failed: $!";
while (my $line = <$fh>) {
	if ($line =~ /^\s*Ref Number\s*(\S+)/) {
		my $refno = $1;
		my $address = ""; my $proposal = ""; my $case_officer = ""; my $date_received;
		my $cur_field;
		my $near_end;
		while (1) {
			chomp $line;
			$line =~ s/^\s+//; $line =~ s/\s+$//;
			if ($line =~ s/^Location of Works//) {
				$cur_field = \$address;
			} elsif ($line =~ s/^Description of Works//) {
				$cur_field = \$proposal;
			} elsif ($line =~ s/^Case Officer//) {
				$cur_field = \$case_officer;
			} elsif (($line =~ s/^Community Council//) || ($line =~ s/^Applicant Name//) || ($line =~ s/^Applicant Address//)) {
				$cur_field = undef;
			} elsif ($line =~ /^Validation Date\s*(\S+)/) {
				$date_received = $1;
				$cur_field = undef;
			}
			$line =~ s/^\s+//;
			if (defined $cur_field) {
				$$cur_field .= " " if $$cur_field ne "";
				$$cur_field .= $line;
			}
			last unless defined ($line = <$fh>);
			last if $near_end && length $line == 1;
			$near_end = 1 if $line =~ /^\s*Case Officer/;
		}
		my $postcode = "None";
		if ($address =~ /([A-Z][A-Z]?\d(\d|[A-Z])? ?\d[A-Z][A-Z])/) {
			$postcode = $1;
		}
		my $comment_url = "None";
		if ($case_officer =~ /([A-Za-z0-9\.]+\@[A-Za-z0-9\.]+)/) {
			$comment_url = "$1";
		}

		$writer->startTag("application");
		$writer->dataElement("council_reference", $refno);
		$writer->dataElement("address", $address);
		$writer->dataElement("postcode", $postcode);
		$writer->dataElement("description", $proposal);
		$writer->dataElement("info_url", $info_url);
		$writer->dataElement("comment_url", $comment_url);
		$writer->dataElement("date_received", $date_received);
		$writer->endTag;
	}
}

$writer->endTag;
$writer->endTag;
$writer->end;
