#!/usr/bin/perl -w

use strict;
use XML::Writer;
use Date::Parse;
use POSIX;

my $file = $ARGV[0];
my $info_url = $ARGV[1];

my $writer = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 2);

$writer->xmlDecl("UTF-8");

$writer->startTag("planning");
$writer->dataElement("authority_name", "North Ayrshire Council");
$writer->dataElement("authority_short_name", "North Ayrshire");
$writer->startTag("applications");

open (my $fh, '-|', "pdftotext", "-layout", $file, "-") or die "open failed: $!";
while (my $line = <$fh>) {
	if ($line =~ /^\s*Application No:\s*(\S+)/) {
		my $refno = $1;
		my $address = ""; my $proposal = ""; my $date_received = "";
		my $cur_field;
		while (1) {
			chomp $line;
			$line =~ s/^\s+//; $line =~ s/\s+$//;
			if ($line =~ s/^Location://) {
				$cur_field = \$address;
			} elsif ($line =~ s/^Description://) {
				$cur_field = \$proposal;
			} elsif ($line =~ s/^Date Registered://) {
				$cur_field = \$date_received;
			} elsif (($line =~ s/^Applicant://) || ($line =~ s/^Agent://) || ($line =~ s/^Ward://)) {
				$cur_field = undef;
			}
			$line =~ s/^\s+//;
			if (defined $cur_field) {
				$$cur_field .= " " if $$cur_field ne "" and $line ne "";
				$$cur_field .= $line;
			}
			last unless defined ($line = <$fh>);
			last if $line =~ /^\s*application:/;
		}
		my $postcode = "None";
		if ($address =~ /([A-Z][A-Z]?\d(\d|[A-Z])? ?\d[A-Z][A-Z])/) {
			$postcode = $1;
		}
		my $norm_date_received = strftime("%d/%m/%Y", map { defined $_ ? $_ : 0 } strptime($date_received));

		$writer->startTag("application");
		$writer->dataElement("council_reference", $refno);
		$writer->dataElement("address", $address);
		$writer->dataElement("postcode", $postcode);
		$writer->dataElement("description", $proposal);
		$writer->dataElement("info_url", $info_url);
		$writer->dataElement("comment_url", 'dcontrol@north-ayrshire.gov.uk');
		$writer->dataElement("date_received", $norm_date_received);
		$writer->endTag;
	}
}

$writer->endTag;
$writer->endTag;
$writer->end;
