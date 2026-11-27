#!/usr/bin/env perl

use v5.16;
use warnings;
use JSON::PP;
use File::Basename;
use lib dirname(__FILE__);
require 'generated/ez-code.pl';

my @args = ();
my $libhdr = 1;
my $autorun = 0;
my $outlang = 's';
for my $a (@ARGV) {
    if ($a =~ /\-(js|pl|php|py|ast)/) {
        $outlang = $1;
    } elsif ($a eq '-bare') {
        $libhdr = 0;
    } elsif ($a eq '-lib') {
        $libhdr = 2
    } elsif ($a eq '-run') {
        $autorun = 1;
    } else {
        push @args, $a;
    }
}
my $outfile = $args[1] // '';

my $data = do {
    open(my $f, '<', $args[0]) or die 'Specify file-name in cmdline';
    undef $/;
    <$f>;
};

my $ast = to_ast($data);

if ($outlang eq 'ast') {
    print JSON::PP->new->pretty->encode($ast);
    exit(0);
}

if ($outlang eq '') {
    $outlang = ($outfile =~ s/.*\.//r) || 'pl';
}

$outlang = 'pl' unless $outlang =~ 'pl|js|php|py';

my $code = ast_to_str($ast, $outlang, 2, $autorun ? 0 : $libhdr);
if ($autorun) {
    eval($code);
    if ($@) {
        say "Error: $@";
        exit(1);
    }
    exit(0);
}
if ($outfile) {
    open(my $f, '>', $outfile);
    print $f $code;
} else {
    print $code;
}

