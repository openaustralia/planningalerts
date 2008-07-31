#!/usr/bin/perl -w

use strict;
use XML::Writer;

my $file = $ARGV[0];
my $info_url = $ARGV[1];

my $writer = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 2);

$writer->xmlDecl("UTF-8");

$writer->startTag("planning");
$writer->dataElement("authority_name", "Newport City Council");
$writer->dataElement("authority_short_name", "Newport");
$writer->startTag("applications");

open (my $fh, '-|', "pdftotext", "-layout", $file, "-") or die "open failed: $!";
while (my $line = <$fh>) {
	if ($line =~ /^\s*App No:\s*(\S+)/) {
		my $refno = $1;
		my $address = ""; my $proposal = ""; my $date_received;
		my $cur_field;
		my $near_end;
		while (1) {
			chomp $line;
			$line =~ s/^\s+//; $line =~ s/\s+$//;
			if ($line =~ s/^ApplicationSite://) {
				$cur_field = \$address;
			} elsif ($line =~ s/^Proposal://) {
				$cur_field = \$proposal;
			} elsif (($line =~ s/^Applicant://) || ($line =~ s/^Agent://) || ($line =~ s/^App Type://)) {
				$cur_field = undef;
			} elsif ($line =~ /^Date Registered:\s*(\S+)/) {
				$date_received = $1;
				$cur_field = undef;
			}
			$line =~ s/^\s+//;
			if (defined $cur_field) {
				$$cur_field .= " " if $$cur_field ne "" and $line ne "";
				$$cur_field .= $line;
			}
			last unless defined ($line = <$fh>);
			last if $near_end && length $line == 1;
			$near_end = 1 if $line =~ /^\s*Case Officer:/;
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
		$writer->dataElement("comment_url", 'planning@newport.gov.uk');
		$writer->dataElement("date_received", $date_received);
		$writer->endTag;
	}
}

$writer->endTag;
$writer->endTag;
$writer->end;
