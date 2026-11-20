use v5.10;use warnings;
sub asplit{my @res = split($_[0],$_[1]); \@res;}
sub ashift{shift @{$_[0]};}
sub writeln{say(@_);}
sub callname{(\&{$_[0]})->(@{$_[1]});}
sub scmp{$_[0] cmp $_[1];}
sub subst{$_[0] =~ s/$_[1]/$_[2]/rg;}
sub haskey{defined $_[1]->{$_[0]};}
sub apush{push @{$_[0]}, $_[1];}
sub len{scalar @{$_[0]};}
sub match{$_[0] =~ qr/$_[1]/;}
sub ajoin{join $_[0], @{$_[1]}}
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
my $pos=[1,1];
sub adv{my () = @_;
  my $c=ashift($data);
  if(scmp($c,"\n")!=0){
    $$pos[1]+=1;
  }
  else{
    $$pos[0]+=1;
    $$pos[1]=1;
  }
  return $c;
}
sub peek{my () = @_;
  return $$data[0];
}
sub err{my ($msg) = @_;
  writeln($msg," at ",ajoin(":",$pos));
  exit(1);
}
sub p_asgn{my ($target) = @_;
  p_space();
  my $op=adv();
  if(scmp($op,"=")!=0){
    if(!match($op,"[\\+\\-\\*\\/%\\.]")||scmp(adv(),"=")!=0){
      err("expected '=' in assignment");
    }
    $op.="=";
  }
  p_space();
  return ["asgn",$target,$op,p_expr()];
}
sub p_def{my () = @_;
  p_space();
  my $var=p_var(p_word());
  p_space();
  if(scmp(peek(),"=")==0){
    $var=p_asgn($var);
  }
  return ["def",$var];
}
sub p_expr{my () = @_;
  return p_num();
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
sub p_space{my () = @_;
  while(match(peek(),"[\\s#]")){
    if(scmp(adv(),"#")==0){
      while(scmp(peek(),"\n")!=0&&scmp(peek(),"\0")!=0){
        adv();
      }
    }
  }
}
sub p_var{my ($name) = @_;
  return ["var",subst($name,"^\\\$","")];
}
sub p_var_indexed{my ($name) = @_;
  return p_var($name);
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
  if(scmp(peek(),"(")==0){
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
    if(scmp(peek(),"\0")==0||scmp(peek(),"}")==0){
      last;
    }
    my $st=stmt($res);
    apush($res,$st);
    p_space();
    if(scmp($$st[len($st)-1],"blk")!=0&&scmp(adv(),";")!=0){
      err("expected ';' at the end of statement");
    }
  }
  return $res;
}
sub to_ast{my ($code) = @_;
  $data=asplit("",$code);
  apush($data,"\0");
  my $ast=stlist();
  if(scmp(peek(),"\0")!=0){
    err("statement expected");
  }
  return $ast;
}
