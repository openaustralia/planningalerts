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
$writer->dataElement("authority_name", "London Borough of Redbridge");
$writer->dataElement("authority_short_name", "Redbridge");
$writer->startTag("applications");

open (my $fh, '-|', "pdftotext", "-layout", $file, "-") or die "open failed: $!";
while (my $line = <$fh>) {
	$line =~ s///g;
	chomp $line;
	if ($line =~ /^\s*(App\.No:)\s*(Location:)\s+(Agent)/) {
		my $ofs_col1 = $-[1];
		my $ofs_col2 = $-[2];
		my $ofs_col3 = $-[3];
		my $col1_full = ""; # sometimes col1 headings break up onto 2 lines so grab the whole thing and match on it
		my $address = ""; my $proposal = "";
		my $cur_field = \$address;
		my $near_end = 0; my $redo_outer = 0;
		while ($line = <$fh>) {
			if ($line =~ s///g) { # alignment may have changed for new page, take care of adjustments of at most 2
			                        # we may lose a few characters but luckily a page break during an entry doesn't
			                        # happen very often (only 4 times during 2005-July 2008)
				$ofs_col2 -= 2;
				$ofs_col3 -= 2;
			}

			if ($line =~ /^\s*App\.No:/) {
				$redo_outer = 1;
				last;
			}

			chomp $line;
			if ($line =~ /^\s{10,}[0-9]+\s*$/) { # a line with a page number... ignore unless near end
				if ($near_end) {
					last;
				} else {
					next;
				}
			}
			my $col1; my $col2;
			if (length $line > $ofs_col1) {
				$col1 = substr $line, $ofs_col1, $ofs_col2-$ofs_col1;
			} else {
				$col1 = "";
			}
			if (length $line > $ofs_col2) {
				$col2 = substr $line, $ofs_col2, $ofs_col3-$ofs_col2;
			} else {
				$col2 = "";
			}
			
			$col2 =~ s/\s{10,}\S.*//g; # remove any obvious spillover text (only needed for a page break during an entry)

			$col1 =~ s/^\s+//; $col1 =~ s/\s+$//;
			$col2 =~ s/^\s+//; $col2 =~ s/\s+$//;

			$col1_full .= " " if $col1_full ne "" and $col1 ne "";
			$col1_full .= $col1;

			if ($col2 eq "") {
				if ($proposal eq "") {
					$cur_field = \$proposal;
				} else {
					$cur_field = undef;
				}
			} elsif (defined $cur_field) {
				$$cur_field .= " " if $$cur_field ne "" and $col2 ne "";
				$$cur_field .= $col2;
			}
			last if $near_end and $line =~ /^\s*$/;
			$near_end = 1 if $col1_full =~ /Case Officer/;
		}
		my ($refno, $date_received) = ($col1_full =~ /^(.+) Deposit Date: (\S+)/);
		$refno ||= ""; $date_received ||= "";
		$refno =~ s/-? //g;

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
		$writer->dataElement("comment_url", 'planning.enquiry@redbridge.gov.uk');
		$writer->dataElement("date_received", $norm_date_received);
		$writer->endTag;

		if ($redo_outer) {
			$redo_outer = 0;
			redo;
		}
	}
}

$writer->endTag;
$writer->endTag;
$writer->end;
