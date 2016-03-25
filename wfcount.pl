#!/usr/bin/perl

my $file = $ARGV[0];
open FH, "< $file" or die "could not open file $file: $!\n";
my %wf = ();  ## empty hash table to store words and their occurances laters

## read input file
while (<FH>) {
	my @word_list = split(/\s+/,$_);
	foreach my $word (@word_list) {
		$wf{$word} = $wf{$word} + 1;
		}
	}
while (($key,$value) = each %wf) {
	print "$key => $value\n";
	}
close(FH);
