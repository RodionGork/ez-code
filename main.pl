use v5.16;
use warnings;
use JSON::PP;
use File::Basename;
use lib dirname(__FILE__);
require 'ez2ast.pl';
require 'ast2out.pl';

my @args = ();
my $outlang = '';
for my $a (@ARGV) {
    if ($a =~ /\-(js|pl|php|ast|run)/) {
        $outlang = $1;
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

my $autorun = ($outlang eq 'run');
$outlang = 'pl' unless $outlang =~ 'pl|js|php';

my $code = ast_to_str($ast, $outlang, 2);
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

