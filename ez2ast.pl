use v5.16;
use warnings;

my %keywords = (
    'def' => \&p_def,
    'while' => \&p_cond,
    'if' => \&p_cond,
    'ret' => \&p_ret,
);

my $data;
my @pos = (1, 1);

sub adv {
    my $c = shift @$data;
    if ($c ne "\n") {
        $pos[1] += 1;
    } else {
        $pos[0] += 1;
        $pos[1] = 1;
    }
    return $c;
}

sub peek {
    return $$data[0];
}

sub err {
    say $_[0] . ' at ' . join(':', @pos);
    exit(1);
}

sub p_space {
    adv while peek =~ /\s/;
}

sub p_word {
    my $w = '';
    $w .= adv while peek =~ /\w/;
    return $w;
}

sub p_num {
    my $n = '';
    $n .= adv while peek =~ /\d/;
    return ['num', $n];
}

sub p_str {
    my $quote = adv;
    my $res = '';
    my $esc = 0;
    my $start = join(':', @pos);
    while (1) {
        my $c = adv;
        err("unterminated string literal starting at $start") if $c eq "\0";
        if (!$esc) {
            last if $c eq $quote;
            $esc = 1 if $c eq '\\';
        } else {
            $esc = 0;
        }
        $res .= $c;
    }
    return ['str', $res];
}

sub p_var {
    err("expected '\$' to start var name") unless adv eq '$';
    return ['var', p_word];
}

sub p_lval {
    return p_var;
}

sub p_val {
    return p_var if peek eq '$';
    return p_num if peek =~ /\d/;
    return p_str if peek eq '"';
    return p_call(p_word) if peek =~ /[A-Z]/i;
    if (adv eq '(') {
        my $ex = p_expr();
        p_space;
        err("expected ')' to end subexpression") unless adv eq ')';
        return ['brex', $ex];
    }
    err("expected value");
}

sub p_mul {
    my @res = (p_val);
    p_space;
    while (peek =~ /[\*\/%]/) {
        p_space;
        push @res, ['op', adv];
        p_space;
        push @res, p_val;
    }
    return @res > 1 ? \@res : $res[0];
}

sub p_sum {
    my @res = (p_mul);
    p_space;
    while (peek =~ /[\+\-\.]/) {
        p_space;
        push @res, ['op', adv];
        p_space;
        push @res, p_mul;
    }
    return @res > 1 ? \@res : $res[0];
}

sub fetch_cmp_op {
    my $op = adv;
    if ($op eq '<' || $op eq '>') {
        $op .= adv if peek eq '=';
        return $op;
    }
    err("unknown comparison operator") unless adv eq '=';
    return $op . '=';
}

sub p_cmp {
    my @res = (p_sum);
    p_space;
    while (peek =~ /[\<\>\!=]/) {
        p_space;
        push @res, ['op', fetch_cmp_op];
        p_space;
        push @res, p_sum;
    }
    return @res > 1 ? \@res : $res[0];
}

sub p_expr {
    return p_cmp;
}

sub p_asgn {
    my $tgt = p_lval;
    p_space;
    my $op = adv;
    if ($op ne '=') {
        if ($op =~ /[\+\-\*\/%\.]/ && adv eq '=') {
            $op .= '=';
        } else {
            err("expected '=' in assignment") unless adv eq '=';
        }
    } 
    p_space;
    return ['asgn', $tgt, $op, p_expr];
}

sub p_def {
    p_space;
    return ['def', p_asgn] if peek eq '$';
    my $fname = p_word;
    p_space;
    err("expected '(' in func definition") unless adv eq '(';
    my $args = [];
    p_space;
    if (peek ne ')') {
        while (1) {
            push @$args, p_var;
            p_space;
            my $rbr = adv;
            last if $rbr eq ')';
            err("expected ')' or ',' in func arguments") unless $rbr eq ',';
            p_space;
        }
    } else {
        adv;
    }
    p_space;
    err("expected '{' to start func body") unless adv eq '{';
    my $body = p_stlist();
    p_space;
    err("expected '}' to end func body") unless adv eq '}';
    return ['defn', $fname, $args, $body, 'blk'];
}

sub p_cond {
    my $res = [$_[0]];
    p_space;
    err("expected '(' before loop condition") unless adv eq '(';
    p_space;
    push @$res, p_expr;
    p_space;
    err("expected ')' after loop condition") unless adv eq ')';
    p_space;
    if (peek eq '{') {
        adv;
        push @$res, p_stlist(), 'blk';
        p_space;
        err("expected '}' to end block") unless adv eq '}';
    } else {
        push @$res, [p_stmt()];
    }
    return $res;
}

sub p_call {
    my $fname = $_[0];
    p_space;
    err("expected '(' for function call") unless adv eq '(';
    my $args = [];
    p_space;
    if (peek ne ')') {
        while (1) {
            push @$args, p_expr;
            p_space;
            my $rbr = adv;
            last if $rbr eq ')';
            err("expected ')' or ',' in argument list") unless $rbr eq ',';
            p_space;
        }
    } else {
        adv;
    }
    return ['call', $fname, $args];
}

sub p_ret {
    p_space;
    return ['ret', p_expr];
}

sub p_stmt {
    p_space;
    if (peek eq '$') {
        return p_asgn;
    } elsif (peek =~ /[A-Z]/i) {
        my $word = p_word;
        if (my $kw = $keywords{$word}) {
            return $kw->($word);
        } else {
            return p_call($word);
        }
    }
    my $code = ord(peek);
    err("unexpected chr($code) at start of statement");
}

sub p_stlist {
    my @res;
    while (1) {
        p_space;
        last if peek eq "\0" || peek eq '}';
        my $st = p_stmt;
        push @res, $st;
        p_space;
        unless ($$st[@$st-1] eq 'blk') {
            err("expected ';' at the end of statement") unless adv eq ';';
        }
    }
    return \@res;
}

sub to_ast {
    my @bytes = split //, $_[0];
    push @bytes, "\0";
    $data = \@bytes;
    my $ast = p_stlist;
    err("statement expected") unless peek eq "\0";
    return $ast;
}

1;
