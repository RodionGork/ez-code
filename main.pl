use v5.16;
use warnings;
use JSON::PP;
use File::Basename;
use lib dirname(__FILE__);
require 'ez2ast.pl';
require 'ast2out.pl';

my @args = ();
my $outlang = 'pl';
for my $a (@ARGV) {
    if ($a =~ /\-(js|pl|php|ast)/) {
        $outlang = $1;
    } else {
        push @args, $a;
    }
}

my $data = do {
    open(my $f, '<', $args[0]) or die 'Specify file-name in cmdline';
    undef $/;
    <$f>;
};

my $ast = to_ast($data);

my $output = $args[1] // '';

if ($outlang eq 'ast') {
    print JSON::PP->new->pretty->encode($ast);
    exit(0);
}

my $code = ast_to_str($ast, $outlang);
if ($output) {
    if ($output ne '-') {
        open(my $f, '>', $args[1]);
        print $f $code;
    } else {
        print $code;
    }
} else {
    eval($code);
    print "Error: $@" if $@;
}
