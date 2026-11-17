use v5.16;
use warnings;

my %keywords = (
    'def' => \&p_def,
    'while' => \&p_cond,
    'if' => \&p_cond,
    'else' => \&p_cond,
    'elsif' => \&p_cond,
    'ret' => \&p_ret,
    'break' => \&p_onekw,
    'cont' => \&p_onekw,
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
    while (peek =~ /[\s#]/) {
        if (adv eq '#') {
            adv while peek ne "\n" && peek ne "\0";
        }
    }
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

sub p_var_indexed {
    my $var = p_var;
    while (peek eq '[' || peek eq '{') {
        my $quote = adv;
        p_space;
        push @$var, [$quote, p_expr()];
        p_space;
        $quote = chr(ord($quote)+2);
        err("expected '$quote' after index expression") if adv ne $quote;
    }
    return $var;
}

sub p_lval {
    return p_var_indexed;
}

sub p_array {
    adv;
    p_space;
    my $res = ['array'];
    if (peek ne ']') {
        while (1) {
            push @$res, p_expr();
            p_space;
            my $rbr = adv;
            last if $rbr eq ']';
            err("expected ']' or ',' in array literal") unless $rbr eq ',';
            p_space;
        }
    } else {
        adv;
    }
    return $res;
}

sub p_hash {
    adv;
    p_space;
    err("expected closing '}' in hash literal") unless adv eq '}';
    return ['hash'];
}

sub p_val {
    return p_var_indexed if peek eq '$';
    return p_num if peek =~ /\d/;
    return p_str if peek eq '"';
    return p_call(p_word) if peek =~ /[A-Z]/i;
    return p_array if peek eq '[';
    return p_hash if peek eq '{';
    if (adv eq '(') {
        my $ex = p_expr();
        p_space;
        err("expected ')' to end subexpression") unless adv eq ')';
        return ['brex', $ex];
    }
    err("expected value");
}

sub array_or_single {
    my $arr = $_[0];
    return @$arr > 1 ? $arr : $$arr[0];
}

sub p_mul {
    my @res = (p_val);
    p_space;
    while (peek =~ /[\*\/%]/) {
        push @res, ['op', adv];
        p_space;
        push @res, p_val;
        p_space;
    }
    return array_or_single(\@res);
}

sub p_sum {
    my @res = (p_mul);
    p_space;
    while (peek =~ /[\+\-\.]/) {
        push @res, ['op', adv];
        p_space;
        push @res, p_mul;
        p_space;
    }
    return array_or_single(\@res);
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
        push @res, ['op', fetch_cmp_op];
        p_space;
        push @res, p_sum;
        p_space;
    }
    return array_or_single(\@res);
}

sub p_and {
    my @res = (p_cmp);
    p_space;
    while (peek eq '&') {
        adv;
        err("expected second '&' in AND operator") unless adv eq '&';
        p_space;
        push @res, ['op', '&&'], p_cmp;
        p_space;
    }
    return array_or_single(\@res);
}

sub p_or {
    my @res = (p_and);
    p_space;
    while (peek eq '|') {
        adv;
        err("expected second '|' in OR operator") unless adv eq '|';
        p_space;
        push @res, ['op', '||'], p_and;
        p_space;
    }
    return array_or_single(\@res);
}

sub p_expr {
    return p_or;
}

sub p_asgn {
    my $tgt = @_ ? $_[0] : p_lval;
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
    if (peek eq '$') {
        my $var = p_var;
        p_space;
        $var = p_asgn($var) if peek eq '='; 
        return ['def', $var];
    }
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

sub p_onekw {
    return ['kw1', $_[0]];
}

sub p_cond {
    my ($kw, $prev) = @_;
    my $res = [$_[0]];
    err("$kw without preceding if") if $kw =~ /else|elsif/ && (!@$prev || !($$prev[-1][0] =~ /if|elsif/));
    p_space;
    if ($kw ne 'else') {
        err("expected '(' before condition") unless adv eq '(';
        p_space;
        push @$res, p_expr;
        p_space;
        err("expected ')' after condition") unless adv eq ')';
        p_space;
    }
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
    my $preceding = $_[0];
    p_space;
    if (peek eq '$') {
        return p_asgn;
    } elsif (peek =~ /[A-Z]/i) {
        my $word = p_word;
        if (my $kw = $keywords{$word}) {
            return $kw->($word, $preceding);
        } else {
            return p_call($word);
        }
    }
    my $code = ord(peek);
    err("unexpected chr($code) at start of statement");
}

sub p_stlist {
    my $res = [];
    while (1) {
        p_space;
        last if peek eq "\0" || peek eq '}';
        my $st = p_stmt($res);
        push @$res, $st;
        p_space;
        unless ($$st[@$st-1] eq 'blk') {
            err("expected ';' at the end of statement") unless adv eq ';';
        }
    }
    return $res;
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
