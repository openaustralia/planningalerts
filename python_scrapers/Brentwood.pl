#!/usr/bin/perl -w

use strict;
use XML::Writer;

my $file = $ARGV[0];
my $info_url = $ARGV[1];
my $date = $ARGV[2];

my $writer = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 2);

$writer->xmlDecl("UTF-8");

$writer->startTag("planning");
$writer->dataElement("authority_name", "Brentwood Borough Council");
$writer->dataElement("authority_short_name", "Brentwood");
$writer->startTag("applications");

open (my $fh, "pdftotext -layout $file -|");
while (my $line = <$fh>) {
	chomp $line;
	$line =~ s///g;
	if ($line =~ /Address:/) {
		my $ofs_col2 = $-[0];
		my $refno = substr $line, 0, $ofs_col2;
		$refno =~ s/ +$//g;
		my $address = ""; my $proposal = "";
		my $cur_field;
		while (1) {
			if (length($line) > $ofs_col2) {
				my $col2 = substr $line, $ofs_col2;
				$col2 =~ s/^ +//;
				if ($col2 =~ s/^((A?d)?d)?ress://) {
					$cur_field = \$address;
				} elsif ($col2 =~ s/^((P?r)?o)?posal://) {
					$cur_field = \$proposal;
				} elsif ($col2 =~ s/^((A?p)?p)?licant://) {
					$cur_field = undef;
				} elsif ($col2 =~ s/^((A?g)?e)?nt://) {
					$cur_field = undef;
				}
				$col2 =~ s/^ +//; $col2 =~ s/ +$//;
				if (defined $cur_field) {
					$$cur_field .= " " if $$cur_field ne "";
					$$cur_field .= $col2;
				}
			}
			last unless defined ($line = <$fh>);
			chomp $line;
			$line =~ s///g;
			last if length $line == 0;
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
		$writer->dataElement("comment_url", "planning\@brentwood.gov.uk");
		$writer->dataElement("date_received", $date);
		$writer->endTag;
	}
}

$writer->endTag;
$writer->endTag;
$writer->end;
