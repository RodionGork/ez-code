use v5.16;
use warnings;

my %subs = ();

my $specific = {
    'pl' => {
        'lang' => 'pl',
        'concat_op' => '.',
        'var_start' => '$',
        'varx_start' => '$',
        'hash_quote' => '{',
        'var_def' => 'my',
        'fn_def' => 'sub',
        'break' => 'last',
        'cont' => 'next',
        'header' => "use v5.10;use warnings;\n",
        'push' => ['apush', 'sub apush{push @{$_[0]}, $_[1];}'],
        'writeln' => 'sub writeln{say(@_);}',
    },
    'js' => {
        'lang' => 'js',
        'concat_op' => '+',
        'var_start' => '',
        'varx_start' => '',
        'hash_quote' => '[',
        'var_def' => 'let',
        'fn_def' => 'function',
        'break' => 'break',
        'cont' => 'continue',
        'elsif' => 'else if',
        'push' => 'function push(a,x){a.push(x)}',
        'writeln' => 'function writeln(..._){console.log(_.join(""))}',
        'atan2' => 'function atan2(a,b){return Math.atan2(a,b)}',
    },
    'php' => {
        'lang' => 'php',
        'concat_op' => '.',
        'var_start' => '$',
        'varx_start' => '',
        'hash_quote' => '[',
        'var_def' => '',
        'fn_def' => 'function',
        'break' => 'break',
        'cont' => 'continue',
        'elsif' => 'elseif',
        'header' => "<?php\n",
        'push' => 'function push(&$a,$x){$a[]=$x;}',
        'writeln' => 'function writeln(...$args){echo implode("", $args)."\n";}',
    },
    'py' => {
        'lang' => 'py',
        'concat_op' => '+',
        '&&' => ' and ',
        '||' => ' or ',
        'var_start' => '',
        'varx_start' => '',
        'hash_quote' => '[',
        'var_def' => '',
        'fn_def' => 'def',
        'break' => 'break',
        'cont' => 'continue',
        'elsif' => 'elif',
        'header' => "import math\n",
        'push' => 'def push(a,x): a.append(x)',
        'atan2' => 'def atan2(a,b): return math.atan2(a,b)',
        'writeln' => 'def writeln(*args): print(*args)',
    },
};

my $spc;
my $indent;

sub expr_to_str {
    my $expr = $_[0];
    $expr = [$expr] unless ref($$expr[0]);
    my $res = '';
    my $elem = $$expr[0];
    my $type = $$elem[0];
    if ($type eq'op') {
        my @a = @$expr[1 .. @$expr-2];
        my $a = expr_to_str(\@a);
        my $b .= expr_to_str([$$expr[-1]]);
        my $op = $$elem[1];
        if ($op eq '.') {
        	$op = $$spc{'concat_op'};
        	$op = " . " if $op eq '.';
        	if ($$spc{'lang'} eq 'py') {
        	    $a = "str($a)";
        	    $b = "str($b)";
        	}
        }
        $op = $$spc{$op}//$op;
        $res .= $a . $op . $b;
    } elsif ($type eq 'num') {
        $res .= $$elem[1];
    } elsif ($type eq 'str') {
        $res .= '"' . $$elem[1] . '"';
    } elsif ($type eq 'var') {
        $res .= var_to_str($elem);
    } elsif ($type eq 'brex') {
        $res .= '(' . expr_to_str($$elem[1]) . ')';
    } elsif ($type eq 'call') {
        $res .= call_to_str($elem);
    } elsif ($type eq 'array') {
        $res .= array_to_str($elem);
    } elsif ($type eq 'hash') {
        $res .= hash_to_str($elem);
    } elsif (ref($$elem[1]) eq 'ARRAY') {
        $res .= expr_to_str($elem);
    } else {
        die "unexpected expression element: " . encode_json($elem);
    }
    return $res;
}

sub array_to_str {
    my $expr = $_[0];
    return '[' . join(',', map {expr_to_str($_)} @$expr[1..@$expr-1]) . ']';
}

sub hash_to_str {
    my $lbr = $$spc{'hash_quote'};
    return $lbr . chr(ord($lbr)+2);
}

sub var_to_str {
    my $elem = $_[0];
    my $res = $$spc{'var_start'} . $$elem[1];
    if (@$elem > 2) {
        $res = $$spc{'varx_start'} . $res;
        for (my $i = 2; $i < @$elem; $i++) {
            my $quote = $$elem[$i][0];
            $quote = $$spc{'hash_quote'} if $quote eq '{';
            $res .= $quote . expr_to_str($$elem[$i][1]) . chr(ord($quote)+2);
        }
    }
    return $res;
}

sub call_to_str {
    my $expr = $_[0];
    my $res = $$expr[1];
    my $def = $$spc{$$expr[1]};
    if (ref($def) eq 'ARRAY') {
        $res = $$def[0];
        $def = $$def[1];
    }
    $subs{$$expr[1]} = $def//'' unless $subs{$$expr[1]};
    $res .= '(';
    $res .= join(',', map {expr_to_str($_)} @{$$expr[2]});
    return $res . ')';
}

sub asgn_to_str {
    my $expr = $_[0];
    my $op = $$expr[2];
    $op = $$spc{'concat_op'} . '=' if $op eq '.='; 
    return expr_to_str($$expr[1]) . $op . expr_to_str($$expr[3]);
}

sub def_to_str {
    my $expr = $_[0];
    my $noinit = $$expr[1][0] eq 'var';
    my $kw = $$spc{'var_def'};
    return if $noinit && !$kw;
    $kw .= ' ' if $kw;
    return $kw . ($noinit ? var_to_str($$expr[1]) : asgn_to_str($$expr[1]));
}

sub block_to_str {
    my ($content, $depth) = @_;
    my $python = $$spc{'lang'} eq 'py';
    my $res = ($python ? ':' : '{') . "\n";
    $res .= stlist_to_str($content, $depth + 1);
    if ($python) {
        chop $res;
    } else {
        $res .= (' ' x ($depth * $indent)) . '}';
    }
    return $res;
}

sub fn_to_str {
    my ($st, $depth) = @_;
    my $args = '(' . join(',', map {$$spc{'var_start'} . $$_[1]} @{$$st[2]}) . ')';
    my $res = "$$spc{'fn_def'} $$st[1]";
    $res .= $args unless $$spc{'lang'} eq 'pl';
    my $block .= block_to_str($$st[3], $depth);
    if ($$spc{'lang'} eq 'pl') {
        my @parts = split /\n/, $block, 2;
        $block = $parts[0] . "my $args = \@_;\n" . $parts[1];
    }
    return $res . $block; 
}

sub cond_to_str {
    my ($st, $depth) = @_;
    push @$st, 'blk' unless $$st[-1] eq 'blk';
    my $kw = $$st[0];
    my $expr = $kw ne 'else' ? '(' . expr_to_str($$st[1]) . ')' : '';
    return ($$spc{$kw}//$kw) . $expr . block_to_str($$st[-2], $depth);
}

sub stmt_to_str {
    my ($st, $depth) = @_;
    if ($$st[0] eq 'call') {
        return call_to_str($st);
    } elsif ($$st[0] eq 'asgn') {
        return asgn_to_str($st);
    } elsif ($$st[0] eq 'def') {
        return def_to_str($st);
    } elsif ($$st[0] eq 'defn') {
        return fn_to_str($st, $depth);
    } elsif ($$st[0] eq 'kw1') {
        return $$spc{$$st[1]};
    } elsif ($$st[0] eq 'ret') {
        return 'return ' . expr_to_str($$st[1]);
    } elsif ($$st[0] =~ 'if|elsif|else|while') {
        return cond_to_str($st, $depth);
    }
    return 'unknown_statement';
}

sub stlist_to_str {
    my ($ast, $depth) = @_;
    my $res = '';
    for my $st (@$ast) {
        $res .= ' ' x ($depth * $indent);
        $res .= stmt_to_str($st, $depth);
        $res .= ';' unless $$st[-1] eq 'blk';
        $res .= "\n";
    }
    return $res;
}

sub ast_to_str {
    my ($ast, $lang) = @_;
    $indent = $_[2];
    $spc = $$specific{$lang};
    my $prefix = $$spc{'header'}//'';
    my $code = stlist_to_str($ast, 0);
    for my $k (keys %subs) {
        $prefix .= $subs{$k} . "\n" if $subs{$k};
    }
    return $prefix . $code;
}

1;
