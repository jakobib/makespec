#!/usr/bin/perl
#ABSTRACT: Include files, such as `file.md`{.include}

# This hack should be replaced by a clean plugin

use v5.14;

while(<>) {
    if (/^`([^`]+)`\{\.include((\s+\.[a-z]+)*)\s*\}\s*$/) {
        my $file = $1;
        my @options = split /\s+/, $2; shift @options;

        my $codeblock;
        if (@options and $options[0] eq '.codeblock') {
            $codeblock = '```';
            shift @options;
            $codeblock .= '{'.join(" ",@options).'}' if @options;
        }

        if (-e $file && open my $fh, '<', $file) {
            say $codeblock if $codeblock;
            local $/;
            print <$fh>;
            close $fh;
            say "```" if $codeblock;
        } else {
            print STDERR "failed to include file $file\n";
        }
    } else {
        print $_;
    }
}
