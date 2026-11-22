use v5.16;use warnings;
sub callname{(\&{$_[0]})->(@{$_[1]});}
sub streq{$_[0] eq $_[1];}
sub halt{say($_[1]);exit($_[0]);}
sub haskey{defined $_[1]->{$_[0]};}
sub ajoin{join $_[0], @{$_[1]}}
sub len{scalar @{$_[0]};}
sub match{$_[0] =~ qr/$_[1]/;}
sub apush{push @{$_[0]}, $_[1];}
sub asplit{my @res = split($_[0],$_[1]); \@res;}
sub subst{$_[0] =~ s/$_[1]/$_[2]/rg;}
sub aunshift{unshift @{$_[0]}, $_[1];}
my $kws={};
$$kws{"def"}="p_def";
$$kws{"fn"}="p_defn";
$$kws{"while"}="p_cond";
$$kws{"if"}="p_cond";
$$kws{"else"}="p_cond";
$$kws{"elsif"}="p_cond";
$$kws{"ret"}="p_ret";
$$kws{"break"}="p_onekw";
$$kws{"cont"}="p_onekw";
my $data;
my $cur=0;
my $pos=[1,1];
sub adv{my () = @_;
  my $c=$$data[$cur];
  $cur+=1;
  if(!streq($c,"\n")){
    $$pos[1]+=1;
  }
  else{
    $$pos[0]+=1;
    $$pos[1]=1;
  }
  return $c;
}
sub peek{my () = @_;
  return $$data[$cur];
}
sub err{my ($msg) = @_;
  halt(1,$msg . " at " . ajoin(":",$pos));
}
sub fetch_cmp_op{my () = @_;
  my $op=adv();
  if(match($op,"[\\<\\>]")){
    if(streq(peek(),"=")){
      $op.=adv();
    }
    return $op;
  }
  if(!streq(adv(),"=")){
    err("unknown comparison operator");
  }
  return $op . "=";
}
sub fetch_log_op{my () = @_;
  my $op=adv();
  if(!streq(adv(),$op)){
    err("unknown logic operator");
  }
  return $op . $op;
}
sub p_array{my () = @_;
  adv();
  p_space();
  my $res=["array"];
  if(!streq(peek(),"]")){
    while(1){
      apush($res,p_expr());
      p_space();
      my $rbr=adv();
      if(streq($rbr,"]")){
        last;
      }
      if(!streq($rbr,",")){
        err("expected ']' or ',' in array literal");
      }
      p_space();
    }
  }
  else{
    adv();
  }
  return $res;
}
sub p_asgn{my ($target) = @_;
  p_space();
  my $op=adv();
  if(!streq($op,"=")){
    if(!match($op,"[\\+\\-\\*\\/%\\.]")||!streq(adv(),"=")){
      err("expected '=' in assignment");
    }
    $op.="=";
  }
  p_space();
  return ["asgn",$target,$op,p_expr()];
}
sub p_assoc{my () = @_;
  adv();
  p_space();
  my $res=["hash"];
  if(!streq(peek(),"}")){
    while(1){
      if(!streq(peek(),"\"")){
        err("expected string for key in hash literal");
      }
      apush($res,p_str());
      p_space();
      if(!streq(adv(),":")){
        err("expected ':' after key in hash literal");
      }
      p_space();
      apush($res,p_expr());
      p_space();
      my $rbr=adv();
      if(streq($rbr,"}")){
        last;
      }
      if(!streq($rbr,",")){
        err("expected '}' or ',' in hash literal");
      }
      p_space();
    }
  }
  else{
    adv();
  }
  return $res;
}
sub p_block{my ($res) = @_;
  adv();
  apush($res,stlist());
  apush($res,"blk");
  p_space();
  if(!streq(adv(),"}")){
    err("expected '}' to end block");
  }
}
sub p_call{my ($fname) = @_;
  p_space();
  if(!streq(adv(),"(")){
    err("expected '(' for function call");
  }
  my $args=[];
  p_space();
  if(!streq(peek(),")")){
    while(1){
      apush($args,p_expr());
      p_space();
      my $rbr=adv();
      if(streq($rbr,")")){
        last;
      }
      if(!streq($rbr,",")){
        err("expected ')' or ',' in argument list");
      }
      p_space();
    }
  }
  else{
    adv();
  }
  return ["call",$fname,$args];
}
sub p_cond{my ($kw,$prev) = @_;
  my $res=[$kw];
  if(match($kw,"else|elsif")&&(len($prev)==0||!match($$prev[len($prev)-1][0],"if|elsif"))){
    err($kw . " without preceding if");
  }
  p_space();
  if(!streq($kw,"else")){
    if(!streq(adv(),"(")){
      err("expected '(' before condition");
    }
    p_space();
    apush($res,p_expr());
    p_space();
    if(!streq(adv(),")")){
      err("expected ')' after condition");
    }
    p_space();
  }
  if(streq(peek(),"{")){
    p_block($res);
  }
  else{
    apush($res,[stmt()]);
  }
  return $res;
}
sub p_def{my () = @_;
  p_space();
  my $var=p_var(p_word());
  p_space();
  if(streq(peek(),"=")){
    $var=p_asgn($var);
  }
  return ["def",$var];
}
sub p_defn{my () = @_;
  p_space();
  my $name=p_word();
  p_space();
  if(!streq(peek(),"(")){
    err("expected '(' in function definition");
  }
  adv();
  p_space();
  my $args=[];
  p_space();
  if(!streq(peek(),")")){
    while(1){
      apush($args,p_var(p_word()));
      p_space();
      my $rbr=adv();
      if(streq($rbr,")")){
        last;
      }
      if(!streq($rbr,",")){
        err("expected ')' or ',' in func arguments");
      }
      p_space();
    }
  }
  else{
    adv();
  }
  p_space();
  if(!streq(adv(),"{")){
    err("expected '{' to start func body");
  }
  my $res=["defn",$name,$args];
  p_block($res);
  return $res;
}
sub p_expr{my () = @_;
  return p_ex_or();
}
sub p_ex_and{my () = @_;
  return p_ex_bop("p_ex_cmp","&","fetch_log_op");
}
sub p_ex_bop{my ($fnext,$expr,$fgetop) = @_;
  my $res=[callname($fnext,[])];
  p_space();
  while(match(peek(),$expr)){
    aunshift($res,["op",callname($fgetop,[])]);
    p_space();
    apush($res,callname($fnext,[]));
    p_space();
  }
  if(len($res)==1){
    return $$res[0];
  }
  return $res;
}
sub p_ex_cmp{my () = @_;
  return p_ex_bop("p_ex_sum","[\\<\\>\\!=]","fetch_cmp_op");
}
sub p_ex_mul{my () = @_;
  return p_ex_bop("p_value","[\\*\\/%]","adv");
}
sub p_ex_or{my () = @_;
  return p_ex_bop("p_ex_and","\\|","fetch_log_op");
}
sub p_ex_sum{my () = @_;
  return p_ex_bop("p_ex_mul","[\\+\\-\\.]","adv");
}
sub p_onekw{my ($w) = @_;
  return ["kw1",$w];
}
sub p_num{my () = @_;
  my $n="";
  while(match(peek(),"\\d")){
    $n.=adv();
  }
  return ["num",$n];
}
sub p_ret{my () = @_;
  p_space();
  return ["ret",p_expr()];
}
sub p_space{my () = @_;
  while(match(peek(),"[\\s#]")){
    if(streq(adv(),"#")){
      while(!streq(peek(),"\n")&&!streq(peek(),"\0")){
        adv();
      }
    }
  }
}
sub p_str{my () = @_;
  my $quote=adv();
  my $res="";
  my $esc=0;
  my $start=ajoin(":",$pos);
  while(1){
    my $c=adv();
    if(streq($c,"\0")){
      err("unterminated string literal starting at " . $start);
    }
    if(!$esc){
      if(streq($c,$quote)){
        last;
      }
      if(streq($c,"\\")){
        $esc=1;
      }
    }
    else{
      $esc=0;
    }
    $res.=$c;
  }
  return ["str",$res];
}
sub p_unary{my () = @_;
  my $op=adv();
  return ["uop",$op,p_value()];
}
sub p_value{my () = @_;
  if(match(peek(),"[A-Za-z\\\$]")){
    my $name=p_word();
    p_space();
    if(!streq(peek(),"(")){
      return p_var_indexed($name);
    }
    else{
      return p_call($name);
    }
  }
  if(match(peek(),"[\\!\\-]")){
    return p_unary();
  }
  if(match(peek(),"\\d")){
    return p_num();
  }
  if(streq(peek(),"\"")){
    return p_str();
  }
  if(streq(peek(),"[")){
    return p_array();
  }
  if(streq(peek(),"{")){
    return p_assoc();
  }
  if(streq(adv(),"(")){
    my $ex=p_expr();
    p_space();
    if(!streq(adv(),")")){
      err("expected ')' to end subexpression");
    }
    return ["brex",$ex];
  }
  err("value expected in expression");
}
sub p_var{my ($name) = @_;
  return ["var",subst($name,"^\\\$","")];
}
sub p_var_indexed{my ($name) = @_;
  my $var=p_var($name);
  while(match(peek(),"[\\[\\{]")){
    my $quote=adv();
    p_space();
    apush($var,[$quote,p_expr()]);
    p_space();
    $quote=chr(ord($quote)+2);
    if(!streq(adv(),$quote)){
      err("expected '. quote . ' after index expression");
    }
  }
  return $var;
}
sub p_word{my () = @_;
  my $w=adv();
  while(match(peek(),"\\w")){
    $w.=adv();
  }
  return $w;
}
sub stmt{my ($prev) = @_;
  p_space();
  if(!match(peek(),"[A-Za-z\\\$]")){
    err("letter or '\$' expected at start of statement");
  }
  my $word=p_word();
  if(haskey($word,$kws)){
    return callname($$kws{$word},[$word,$prev]);
  }
  p_space();
  if(streq(peek(),"(")){
    return p_call($word);
  }
  else{
    return p_asgn(p_var_indexed($word));
  }
}
sub stlist{my () = @_;
  my $res=[];
  while(1==1){
    p_space();
    if(streq(peek(),"\0")||streq(peek(),"}")){
      last;
    }
    my $st=stmt($res);
    apush($res,$st);
    p_space();
    if(!streq($$st[len($st)-1],"blk")&&!streq(adv(),";")){
      err("expected ';' at the end of statement");
    }
  }
  return $res;
}
sub to_ast{my ($code) = @_;
  $data=asplit("",$code);
  apush($data,"\0");
  my $ast=stlist();
  if(!streq(peek(),"\0")){
    err("statement expected");
  }
  return $ast;
}
