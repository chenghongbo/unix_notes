#!/usr/bin/perl

my $number_of_words = 5;
my $file = $ARGV[0];
open FH, "< $file" or die "could not open file $file: $!\n";
my %wf = ();  ## empty hash table to store words and their occurances laters

## read input file
while (<FH>) {
	## replace special characters with space
	s/[\W|\-|\s+]/ /g;
	my @word_list = split(/\s+/,$_);
	foreach my $word (@word_list) {
		$wf{$word} = $wf{$word} + 1 unless ($word eq "");
		}
	}
my @sorted_words = sort by_value keys %wf;


foreach (0 .. $number_of_words - 1)  {

		print "$sorted_words[$_] => $wf{$sorted_words[$_]}\n";
}
#while (($key,$value) = each %wf) {
#	print "$key => $value\n";
#	}
close(FH);

sub by_value { $wf{$b} <=> $wf{$a}  }
