#!/usr/bin/perl -w

use strict;
use XML::Writer;

my $file = $ARGV[0];
my $info_url = $ARGV[1];

my $writer = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 2);

$writer->xmlDecl("UTF-8");

$writer->startTag("planning");
$writer->dataElement("authority_name", "Glasgow City Council");
$writer->dataElement("authority_short_name", "Glasgow");
$writer->startTag("applications");

open (my $fh, "pdftotext -layout $file -|");
while (my $line = <$fh>) {
	if ($line =~ /^\s*Reference:\s*(\S+)/) {
		my $refno = $1;
		my $address = ""; my $proposal = ""; my $date_received;
		my $cur_field;
		while (1) {
			chomp $line;
			$line =~ s/^\s+//; $line =~ s/\s+$//;
			if ($line =~ s/^Address://) {
				$cur_field = \$address;
			} elsif ($line =~ s/^Proposal://) {
				$cur_field = \$proposal;
			} elsif ($line =~ /^Date Received:\s*(\S+)/) {
				$date_received = $1;
				$date_received =~ s#\.#/#g;
				$cur_field = undef;
			}
			$line =~ s/^\s+//;
			if (defined $cur_field) {
				$$cur_field .= " " if $$cur_field ne "";
				$$cur_field .= $line;
			}
			last if $line =~ /Map Reference:/;
			last unless defined ($line = <$fh>);
		}
		my $postcode = "None";
		if ($address =~ /([A-Z][A-Z]?\d(\d|[A-Z])? ?\d[A-Z][A-Z])/) {
			$postcode = $1;
		}

		$writer->startTag("application");
		$writer->dataElement("council_reference", $refno);
		$writer->dataElement("address", $address);
		$writer->dataElement("postcode", $postcode);
		$writer->dataElement("description", $proposal);
		$writer->dataElement("info_url", $info_url);
		$writer->dataElement("comment_url", "planning.representations\@drs.glasgow.gov.uk");
		$writer->dataElement("date_received", $date_received);
		$writer->endTag;
	}
}

$writer->endTag;
$writer->endTag;
$writer->end;
