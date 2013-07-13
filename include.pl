#!/usr/bin/perl
#ABSTRACT: Include files, such as `file.md`{.include}

# This hack should be replaced by a clean plugin

use v5.14;

while(<>) {
    if (/^`([^`]+)`\{\.include\}\s*$/) {
        if (-e $1 && open my $fh, '<', $1) {
            local $/;
            print <$fh>;
            close $fh;
        } else {
            print STDERR "failed to include file $1\n";
        }
    } else {
        print $_;
    }
}
