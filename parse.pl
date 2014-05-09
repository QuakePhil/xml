#!/usr/bin/perl
use Data::Dumper;
use strict;
use warnings;

sub trim
	{
	my $s = shift;
	$s =~ s/^\s+//;
	$s =~ s/\s+$//;
	return $s;
	}

my $file = 'abc.xml';
open my $xmldata, $file or die "Could not open $file: $!";

my %xml = ();

my $inside_tag = 0;
my $data = '';
my @tagstack = ();

my $tag_counter = 0;


# another idea is to use reduce:
# use List::Util qw(reduce); sub get_ptr { reduce { $a->{$b} ||= {}} $_[0], @$_[1] }
my $ptr;
sub get_ptr
	{
	my $ptr = $_[0];
	foreach (@{$_[1]})
		{
		if (not $ptr->{$_}) { $ptr->{$_} = {}; }
		$ptr = $ptr->{$_};
		}
	return $ptr;
	}

while (defined(my $line = readline($xmldata)))
	{
	$line = trim($line);
	my @chars = split('', $line);

	for my $char(@chars)
		{
		if ($char eq '<')
			{
			$inside_tag = 1;
			$data = '';
			}
		elsif ($char eq '>' and substr($data, 0, 1) eq '?')
			{
			$inside_tag = 0;
			$data = '';
			}
		elsif ($char eq '>' and substr($data, 0, 1) ne '?')
			{
			$inside_tag = 0;
			if (substr($data, 0, 1) eq '/')
				{
				$data = substr($data, 1);
				pop(@tagstack);
				#print "\tClose tag: $data\n";
				}
			else
				{
				++$tag_counter;
				push(@tagstack, $tag_counter);

				my ($open_tag, $rest) = split(' ', $data, 2);
				if (substr($open_tag, -1) eq '/') { $open_tag = substr($open_tag, 0, -1); }
				if ($rest and $rest eq '/') { $rest = ''; }
				#print "\tOpen tag: $data\n";

				$ptr = get_ptr(\%xml, \@tagstack);
				$ptr->{'tag'} = $open_tag;
				$ptr->{'rest'} = $rest;

				if (substr(trim($data), -1) eq '/') { pop(@tagstack); }
				}
			$data = '';
			}
		else
			{
			if ($inside_tag == 0)
				{
				$ptr = get_ptr(\%xml, \@tagstack);
				$ptr->{'data'} .= $char;
				}
			else 	{ $data .= $char; }
			}
		}
	}

close $xmldata;

print Dumper(\%xml);
