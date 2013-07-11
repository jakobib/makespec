#!/usr/bin/perl
#ABSTRACT: Replace variables, such as {FOO}

use v5.14;
use autodie;
my %vars;

while (@ARGV and shift =~ /^([A-Z0-9_]+)(:?)$/) {
    my $value = shift // '';
    if ($2 && $value) {
        die "missing file $value" unless -f $value;
        $value = do { open my $fh, '<', $value; local $/; <$fh>; };
    }
    $vars{$1} = $value;
}

my $keys = join '|', keys %vars;

while (<>) {
    s/\{($keys)\}/$vars{$1}/ge;
    print $_;
}
