use v5.16;
use warnings;

my $funclib = {
    'pl' => {
        'push' => ['sub apush{push @{$_[0]}, $_[1];}', 'apush'],
        'shift' => ['sub ashift{shift @{$_[0]};}', 'ashift'],
        'unshift' => ['sub aunshift{unshift @{$_[0]}, $_[1];}', 'aunshift'],
        'len' => 'sub len{scalar @{$_[0]};}',
        'split' => ['sub asplit{my @res = split($_[0],$_[1]); \@res;}', 'asplit'],
        'join' => ['sub ajoin{join $_[0], @{$_[1]}}', 'ajoin'],
        'match' => 'sub match{$_[0] =~ qr/$_[1]/;}',
        'subst' => 'sub subst{$_[0] =~ s/$_[1]/$_[2]/rg;}',
        'haskey' => 'sub haskey{defined $_[1]->{$_[0]};}',
        'eq' => ['sub streq{$_[0] eq $_[1];}', 'streq'],
        'scmp' => 'sub scmp{$_[0] cmp $_[1];}',
        'halt' => 'sub halt{say($_[1]);exit($_[0]);}',
        'writeln' => 'sub writeln{say(@_);}',
        'callname' => 'sub callname{(\&{$_[0]})->(@{$_[1]});}',
    },
    'js' => {
        'push' => 'function push(a,x){a.push(x)}',
        'len' => 'function len(a){return a.length}',
        'writeln' => 'function writeln(..._){console.log(_.join(""))}',
        'atan2' => 'function atan2(a,b){return Math.atan2(a,b)}',
        'int' => 'function int(x){return Math.floor(x)}',
    },
    'php' => {
        'push' => 'function push(&$a,$x){$a[]=$x;}',
        'len' => 'function len($a){return count($a);}',
        'int' => 'function int($x){return floor($x);}',
        'writeln' => 'function writeln(...$args){echo implode("", $args)."\n";}',
    },
    'py' => {
        'push' => 'def push(a,x): a.append(x)',
        'writeln' => 'def writeln(*args): print(*args, sep="")',
        'atan2' => 'def atan2(a,b): return math.atan2(a,b)',
    },
};

sub funclib {
    return $$funclib{$_[0]};
}

1;
