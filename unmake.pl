#! /usr/bin/env perl
use strict;
use warnings;

use File::Basename;
use File::Spec;
use File::Spec::Functions;


sub parse_inlucde {
    my $path = File::Spec::Functions::rel2abs($_[0]);
    my $dirpath = File::Basename::dirname($path);
    display_usage($path);

    open (my $fp, $path) or die "$!";
    while (<$fp>) {
        if (/^include ([^#]+)/){
            my $tagret_line = $1;
            foreach (split(/ /,  $tagret_line)) {
                my $target_pattern = File::Spec::Functions::rel2abs($_);
                foreach (glob $target_pattern) {
                    my $target_file = $_;
                    parse_inlucde($target_file);
                }
            }
        }
    }
    close($fp);
}


sub display_usage  {
    open (my $fp, $_[0]) or die "$!";
    my $buf =  do { local $/; <$fp> };
    close $fp;

    while ($buf =~ /^([^._][a-zA-Z0-9_\-]*):(.*)\n(^\t\@\##.*\n)?(^\t\@\#\s*\n)?((^\t\@\#.*\n)*)/gm ) {
        my $cmd = $1;
        my $synopsis = $3 || "";
        my $msg = $5 || "";

        $cmd =~ s/\A\s*(.*?)\s*\z/$1/;
        $synopsis =~ s/@##//g;
        $synopsis =~ s/\A\s*(.*?)\s*\z/$1/;
        $msg =~ s/\t\@\#/     /g;
        printf("* %-20s\n\n%s\n\n", $cmd . " " . $synopsis, $msg);
    }
}




foreach (@ARGV) {
    parse_inlucde($_);
}
