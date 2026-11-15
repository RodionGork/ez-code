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
        my $type = $$elem[0];
        if ($type =~ 'num|op') {
            my $op = $$elem[1];
            $op = " $op " if $op eq '.';
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
    return '[]';
}

sub hash_to_str {
    return '{}';
}

sub var_to_str {
    my $elem = $_[0];
    my $res = '$' . $$elem[1];
    if (@$elem > 2) {
        $res = '$' . $res;
        for (my $i = 2; $i < @$elem; $i++) {
            my $quote = $$elem[$i][0];
            $res .= $quote . expr_to_str($$elem[$i][1]) . chr(ord($quote)+2);
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
    return 'my ' . ($$expr[1][0] eq 'var' ? var_to_str($$expr[1]) : asgn_to_str($$expr[1]));
}

sub fn_to_str {
    my $st = $_[0];
    my $args = join(',', map {'$' . $$_[1]} @{$$st[2]});
    my $res = 'sub ' . $$st[1] . " {\n";
    $res .= "my ($args) = \@_;\n";
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

sub outlang_prefix {
    return "use v5.10; use warnings;\n";
}
