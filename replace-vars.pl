#!/usr/bin/perl
#ABSTRACT: Replace variables, such as {FOO}

use v5.14;
my %vars;

while (@ARGV and shift =~ /^([A-Z0-9_]+)$/) {
    $vars{$1} = shift // '';
}

#use Data::Dumper;
#say STDERR Dumper(\%vars);

my $keys = join '|', keys %vars;

while (<>) {
    s/\{($keys)\}/$vars{$1}/ge;
    print $_;
}

