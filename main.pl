use v5.16;
use warnings;
use JSON::PP;
use File::Basename;
use lib dirname(__FILE__);
require 'ez2ast.pl';
require 'ast2pl.pl';

my $data = do {
    open(my $f, '<', $ARGV[0]) or die 'Specify file-name in cmdline';
    undef $/;
    <$f>;
};

my $ast = to_ast($data);

my $output = $ARGV[1] // '';

if ($output eq '-ast') {
    print JSON::PP->new->pretty->encode($ast);
} else {
    my $code = to_pl($ast);
    if ($output) {
        if ($output ne '-') {
            open(my $f, '>', $ARGV[1]);
            print $f "use v5.10; use warnings;\n";
            print $f $code;
        } else {
            print $code;
        }
    } else {
        eval($code);
        print "Error: $@" if $@;
    }
}

