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

#print JSON::PP->new->pretty->encode($ast);

print to_pl($ast);
