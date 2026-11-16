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
        'header' => "<?php\n",
        'writeln' => 'function writeln(...$args){echo implode("", $args)."\n";}',
    },
};

my $spc;

sub expr_to_str {
    my $expr = $_[0];
    $expr = [$expr] unless ref($$expr[0]);
    my $res = '';
    for my $elem (@$expr) {
        my $type = $$elem[0];
        if ($type =~ 'num|op') {
            my $op = $$elem[1];
            if ($op eq '.') {
            	$op = $$spc{'concat_op'};
            	$op = " $op " if $op eq '.';
            }
            $res .= $op;
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
    $subs{$$expr[1]} = $$spc{$$expr[1]}//'' unless $subs{$$expr[1]};
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

sub fn_to_str {
    my $st = $_[0];
    my $args = '(' . join(',', map {$$spc{'var_start'} . $$_[1]} @{$$st[2]}) . ')';
    my $res = "$$spc{'fn_def'} $$st[1]";
    $res .= $args unless $$spc{'lang'} eq 'pl';
    $res .= "{\n";
    $res .= "my $args = \@_;\n" if $$spc{'lang'} eq 'pl';
    $res .= stlist_to_str($$st[3]) . '}';
    return $res; 
}

sub cond_to_str {
    my $st = $_[0];
    my $block = stlist_to_str($$st[2]);
    return $$st[0] . '(' . expr_to_str($$st[1]) . "){\n$block}"; 
}

sub stmt_to_str {
    my $st = $_[0];
    if ($$st[0] eq 'call') {
        return call_to_str($st);
    } elsif ($$st[0] eq 'asgn') {
        return asgn_to_str($st);
    } elsif ($$st[0] eq 'def') {
        return def_to_str($st);
    } elsif ($$st[0] eq 'defn') {
        return fn_to_str($st);
    } elsif ($$st[0] eq 'kw1') {
        return $$spc{$$st[1]};
    } elsif ($$st[0] eq 'ret') {
        return 'return ' . expr_to_str($$st[1]);
    } elsif ($$st[0] =~ 'if|while') {
        return cond_to_str($st);
    }
    return 'unknown_statement';
}

sub stlist_to_str {
    my $res = '';
    for my $st (@{$_[0]}) {
        $res .= stmt_to_str($st);
        $res .= ";\n";
    }
    return $res;
}

sub ast_to_str {
    my ($ast, $lang) = @_;
    $spc = $$specific{$lang};
    my $prefix = $$spc{'header'}//'';
    my $code = stlist_to_str($ast);
    for my $k (keys %subs) {
        $prefix .= $subs{$k} . "\n" if $subs{$k};
    }
    return $prefix . $code;
}

1;
