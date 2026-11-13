use v5.16;
use warnings;

my %keywords = ();

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
    while (peek =~ /[\*\/]/) {
        push @res, ['op', adv];
        push @res, p_val;
    }
    return @res > 1 ? \@res : $res[0];
}

sub p_sum {
    my @res = (p_mul);
    while (peek =~ /[\+\-]/) {
        push @res, ['op', adv];
        push @res, p_mul;
    }
    return @res > 1 ? \@res : $res[0];
}

sub p_expr {
    return p_sum;
}

sub p_asgn {
    my $tgt = p_lval;
    p_space;
    err("expected '=' in assignment") unless adv eq '=';
    return ['asgn', $tgt, p_expr];
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

sub p_stmt {
    p_space;
    if (peek eq '$') {
        return p_asgn;
    } elsif (peek =~ /[A-Z]/i) {
        my $word = p_word;
        if (my $kw = $keywords{$word}) {
            return $kw->();
        } else {
            return p_call($word);
        }
    } elsif (peek eq "\0") {
        return undef;
    }
    my $code = ord(peek);
    err("unexpected chr($code) at start of statement");
}

sub to_ast {
    my @bytes = split //, $_[0];
    push @bytes, "\0";
    $data = \@bytes;
    my @ast;
    while (my $st = p_stmt) {
        push @ast, $st;
        p_space;
        err("expected ';' at the end of statement") unless adv eq ';';
    }
    return \@ast;
}

1;
