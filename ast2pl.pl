use v5.16;
use warnings;

my %subs = (
    'writeln' => 'say',
);

sub expr_to_str {
    my $expr = $_[0];
    $expr = [$expr] unless ref($$expr[0]);
    my $res = '';
    for my $elem (@$expr) {
        if ($$elem[0] =~ 'num|op') {
            my $op = $$elem[1];
            $op = " $op " if $op eq '.';
            $res .= $op;
        } elsif ($$elem[0] eq 'str') {
            $res .= '"' . $$elem[1] . '"';
        } elsif ($$elem[0] eq 'var') {
            $res .= '$' . $$elem[1];
        } elsif ($$elem[0] eq 'brex') {
            $res .= '(' . expr_to_str($$elem[1]) . ')';
        } elsif ($$elem[0] eq 'call') {
            $res .= call_to_str($elem);
        } elsif (ref($$elem[1]) eq 'ARRAY') {
            $res .= expr_to_str($elem);
        } else {
            die "unexpected expression element: " . encode_json($elem);
        }
    }
    return $res;
}

sub call_to_str {
    my $expr = $_[0];
    my $res = $subs{$$expr[1]} // $$expr[1];
    $res .= '(';
    $res .= join(',', map {expr_to_str($_)} @{$$expr[2]});
    return $res . ')';
}

sub asgn_to_str {
    my $expr = $_[0];
    return expr_to_str($$expr[1]) . $$expr[2] . expr_to_str($$expr[3]);
}

sub def_to_str {
    my $expr = $_[0];
    return 'my ' . asgn_to_str($$expr[1]);
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

sub to_pl {
    return stlist_to_str(@_);
}
