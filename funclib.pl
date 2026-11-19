use v5.16;
use warnings;

my $funclib = {
    'pl' => {
        'push' => ['sub apush{push @{$_[0]}, $_[1];}', 'apush'],
        'len' => 'sub len{scalar @{$_[0]};}',
        'writeln' => 'sub writeln{say(@_);}',
    },
    'js' => {
        'push' => 'function push(a,x){a.push(x)}',
        'len' => 'function len(a){return a.length}',
        'writeln' => 'function writeln(..._){console.log(_.join(""))}',
        'atan2' => 'function atan2(a,b){return Math.atan2(a,b)}',
    },
    'php' => {
        'push' => 'function push(&$a,$x){$a[]=$x;}',
        'len' => 'function len($a){return count($a);}',
        'writeln' => 'function writeln(...$args){echo implode("", $args)."\n";}',
    },
    'py' => {
        'push' => 'def push(a,x): a.append(x)',
        'writeln' => 'def writeln(*args): print(*args)',
        'atan2' => 'def atan2(a,b): return math.atan2(a,b)',
    },
};

sub funclib {
    return $$funclib{$_[0]};
}

1;
