#generated file, don't edit directly
use v5.16;use warnings;
my $flib={'pl'=>{'push'=>['sub apush{push @{$_[0]}, $_[1];}','apush'],'shift'=>['sub ashift{shift @{$_[0]};}','ashift'],'unshift'=>['sub aunshift{unshift @{$_[0]}, $_[1];}','aunshift'],'len'=>'sub len{scalar @{$_[0]};}','split'=>['sub asplit{my @res = split($_[0],$_[1],($_[2]//0)); \@res;}','asplit'],'slice'=>'sub slice{my @res = @{$_[0]}[$_[1] .. $_[2]];\@res;}','isarray'=>'sub isarray{ref($_[0]) eq "ARRAY";}','join'=>['sub ajoin{join $_[0], @{$_[1]}}','ajoin'],'sort'=>['sub asort{my @res = sort @{$_[0]};\@res;}','asort'],'match'=>'sub match{$_[0] =~ qr/$_[1]/;}','subst'=>'sub subst{$_[0] =~ s/$_[1]/$_[2]/rg;}','haskey'=>'sub haskey{defined $_[1]->{$_[0]};}','keys'=>['sub hkeys{my @res = keys(%{$_[0]}); \@res;}','hkeys'],'eq'=>['sub streq{$_[0] eq $_[1];}','streq'],'scmp'=>'sub scmp{$_[0] cmp $_[1];}','halt'=>'sub halt{say($_[1]);exit($_[0]);}','writeln'=>'sub writeln{say(@_);}','callname'=>'sub callname{(\&{$_[0]})->(@{$_[1]});}',},'js'=>{'push'=>'function push(a,x){a.push(x)}','len'=>'function len(a){return a.length}','writeln'=>'function writeln(..._){console.log(_.join(""))}','atan2'=>'function atan2(a,b){return Math.atan2(a,b)}','int'=>'function int(x){return Math.floor(x)}',},'php'=>{'push'=>'function push(&$a,$x){$a[]=$x;}','len'=>'function len($a){return count($a);}','int'=>'function int($x){return floor($x);}','writeln'=>'function writeln(...$args){echo implode("", $args)."\n";}',},'py'=>{'push'=>'def push(a,x): a.append(x)','writeln'=>'def writeln(*args): print(*args, sep="")','atan2'=>'def atan2(a,b): return math.atan2(a,b)',},};
sub funclib{ my ($lang)= @_;
  return $$flib{$lang};
}
use v5.16;use warnings;
my $kws={"def"=>"p_def","fn"=>"p_defn","while"=>"p_cond","if"=>"p_cond","else"=>"p_cond","elsif"=>"p_cond","ret"=>"p_onekw","break"=>"p_onekw","cont"=>"p_onekw",};
my $data;
my $cur=0;
my $pos=[1,1];
sub adv{
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
sub peek{
  return $$data[$cur];
}
sub err{ my ($msg)= @_;
  halt(1,$msg . " at " . ajoin(":",$pos));
}
sub fetch_cmp_op{
  my $op=adv();
  if(match($op,'[\<\>]')){
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
sub fetch_log_op{
  my $op=adv();
  if(!streq(adv(),$op)){
    err("unknown logic operator");
  }
  return $op . $op;
}
sub p_array{
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
sub p_asgn{ my ($target)= @_;
  p_space();
  my $op=adv();
  if(!streq($op,"=")){
    if(!match($op,'[\+\-\*\/%\.]')||!streq(adv(),"=")){
      err("expected keyword or '=' for assignment");
    }
    $op.="=";
  }
  p_space();
  return ["asgn",$target,$op,p_expr()];
}
sub p_assoc{
  adv();
  p_space();
  my $res=["hash"];
  if(!streq(peek(),"}")){
    while(1){
      if(!streq(peek(),'"')&&!streq(peek(),"'")){
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
sub p_block{ my ($res)= @_;
  adv();
  apush($res,stlist());
  apush($res,"blk");
  p_space();
  if(!streq(adv(),"}")){
    err("expected '}' to end block");
  }
}
sub p_call{ my ($fname)= @_;
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
sub p_cond{ my ($kw,$prev)= @_;
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
sub p_def{
  p_space();
  my $var=p_var(p_word());
  p_space();
  if(streq(peek(),"=")){
    $var=p_asgn($var);
  }
  return ["def",$var];
}
sub p_defn{
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
sub p_expr{
  my $res=p_ex_or();
  p_space();
  if(!streq(peek(),'?')){
    return $res;
  }
  adv();
  $res=['tern',$res];
  p_space();
  apush($res,p_expr());
  p_space();
  if(!streq(adv(),':')){
    err("expected ':' in ternary operator");
  }
  p_space();
  apush($res,p_expr());
  return $res;
}
sub p_ex_and{
  return p_ex_bop("p_ex_cmp","&","fetch_log_op");
}
sub p_ex_bop{ my ($fnext,$expr,$fgetop)= @_;
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
sub p_ex_cmp{
  return p_ex_bop("p_ex_sum",'[\<\>\!=]',"fetch_cmp_op");
}
sub p_ex_mul{
  return p_ex_bop("p_value",'[\*\/%]',"adv");
}
sub p_ex_or{
  return p_ex_bop("p_ex_and",'\|',"fetch_log_op");
}
sub p_ex_sum{
  return p_ex_bop("p_ex_mul",'[\+\-\.]',"adv");
}
sub p_onekw{ my ($w)= @_;
  my $res=['kw1',$w];
  p_space();
  if(streq($w,'ret')&&!streq(peek(),';')){
    apush($res,p_expr());
  }
  return $res;
}
sub p_num{
  my $n="";
  while(match(peek(),'\d')){
    $n.=adv();
  }
  return ["num",$n];
}
sub p_space{
  while(match(peek(),'[\s#]')){
    if(streq(adv(),"#")){
      while(!streq(peek(),"\n")&&!streq(peek(),"\0")){
        adv();
      }
    }
  }
}
sub p_str{
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
  return ["str",$res,$quote];
}
sub p_unary{
  my $op=adv();
  return ["uop",$op,p_value()];
}
sub p_value{
  if(match(peek(),'[A-Za-z\$]')){
    my $name=p_word();
    p_space();
    if(!streq(peek(),"(")){
      return p_var_indexed($name);
    }
    else{
      return p_call($name);
    }
  }
  if(match(peek(),'[\!\-]')){
    return p_unary();
  }
  if(match(peek(),'\d')){
    return p_num();
  }
  if(streq(peek(),'"')||streq(peek(),"'")){
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
sub p_var{ my ($name)= @_;
  return ["var",subst($name,'^\$',"")];
}
sub p_var_indexed{ my ($name)= @_;
  my $var=p_var($name);
  while(match(peek(),'[\[\{]')){
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
sub p_word{
  my $w=adv();
  while(match(peek(),'\w')){
    $w.=adv();
  }
  return $w;
}
sub stmt{ my ($prev)= @_;
  p_space();
  if(!match(peek(),'[A-Za-z\$]')){
    err('letter or \'$\' expected at start of statement');
  }
  my $word=p_word();
  if(haskey($word,$kws)){
    return callname($$kws{$word},[$word,$prev]);
  }
  p_space();
  if(streq(peek(),"(")){
    return p_call($word);
  }
  return p_asgn(p_var_indexed($word));
}
sub stlist{
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
sub to_ast{ my ($code)= @_;
  $data=asplit("",$code);
  apush($data,"\0");
  my $ast=stlist();
  if(!streq(peek(),"\0")){
    err("statement expected");
  }
  return $ast;
}
use v5.16;use warnings;
my $lib;
my $spc;
my $indent;
my $specific={"pl"=>{"lang"=>"pl","var_start"=>'$',"varx_start"=>'$',"hash_idx_quote"=>"{","var_def"=>"my","fn_def"=>"sub","break"=>"last","cont"=>"next","header"=>"use v5.16;use warnings;\n",},"js"=>{"lang"=>"js","concat_op"=>"+","hash_arrow"=>":","var_def"=>"let","fn_def"=>"function","elsif"=>"else if",},"php"=>{"lang"=>"php","var_start"=>'$',"hash_lit_quote"=>"[","fn_def"=>"function","elsif"=>"elseif","header"=>"<?php\n",},"py"=>{"lang"=>"py","concat_op"=>"+","&&"=>" and ","||"=>" or ","!"=>" not ","hash_arrow"=>":","fn_def"=>"def","elsif"=>"elif","header"=>"import math\n",},};
my $kw1map={'cont'=>'continue','ret'=>'return',};
sub array_to_str{ my ($expr)= @_;
  my $res=[];
  my $i=1;
  while($i<len($expr)){
    apush($res,expr_to_str($$expr[$i]));
    $i+=1;
  }
  return "[" . ajoin(",",$res) . "]";
}
sub asgn_to_str{ my ($expr)= @_;
  my $op=$$expr[2];
  if(streq($op,".=")){
    $op=getwdef($spc,"concat_op",".") . "=";
  }
  return expr_to_str($$expr[1]) . $op . expr_to_str($$expr[3]);
}
sub block_to_str{ my ($content,$depth)= @_;
  my $res=stlist_to_str($content,$depth+1);
  if(streq($$spc{"lang"},"py")){
    $res=":\n" . subst($res,'\s+$',"");
  }
  else{
    $res="{\n" . $res . repstr(" ",$depth*$indent) . "}";
  }
  return $res;
}
sub call_to_str{ my ($expr)= @_;
  my $name=$$expr[1];
  my $definition=getwdef($lib,$name,"");
  if(!streq($definition,"")){
    $$definition[2]=1;
    $name=$$definition[1];
  }
  my $res=$name . "(";
  if(len($$expr[2])!=0){
    my $i=0;
    while(1){
      $res.=expr_to_str($$expr[2][$i]);
      $i+=1;
      if($i>=len($$expr[2])){
        last;
      }
      $res.=",";
    }
  }
  return $res . ")";
}
sub cond_to_str{ my ($st,$depth)= @_;
  if(!streq($$st[len($st)-1],"blk")){
    apush($st,"blk");
  }
  my $kw=$$st[0];
  my $expr="";
  if(!streq($kw,"else")){
    $expr="(" . expr_to_str($$st[1]) . ")";
  }
  return getwdef($spc,$kw,$kw) . $expr . block_to_str($$st[len($st)-2],$depth);
}
sub def_to_str{ my ($expr)= @_;
  my $noinit=streq($$expr[1][0],"var");
  my $kw=getwdef($spc,"var_def","");
  if(streq($kw,"")){
    if($noinit){
      return 0;
    }
  }
  else{
    $kw.=" ";
  }
  if($noinit){
    return $kw . var_to_str($$expr[1]);
  }
  return $kw . asgn_to_str($$expr[1]);
}
sub expr_to_str{ my ($expr)= @_;
  if(!isarray($$expr[0])){
    $expr=[$expr];
  }
  my $elem=$$expr[0];
  my $type=$$elem[0];
  if(streq($type,"op")){
    my $a=expr_to_str(slice($expr,1,len($expr)-2));
    my $b=expr_to_str([$$expr[len($expr)-1]]);
    my $op=$$elem[1];
    if(streq($op,".")){
      $op=getwdef($spc,"concat_op"," . ");
      if(streq($$spc{"lang"},"py")){
        $a="str(" . $a . ")";
        $b="str(" . $b . ")";
      }
    }
    return $a . getwdef($spc,$op,$op) . $b;
  }
  elsif(streq($type,"uop")){
    my $op=$$elem[1];
    return getwdef($spc,$op,$op) . expr_to_str($$elem[2]);
  }
  elsif(streq($type,"tern")){
    return ternary_to_str($elem);
  }
  elsif(streq($type,"num")){
    return $$elem[1];
  }
  elsif(streq($type,"str")){
    return lit_to_str($elem);
  }
  elsif(streq($type,"var")){
    return var_to_str($elem);
  }
  elsif(streq($type,"brex")){
    return "(" . expr_to_str($$elem[1]) . ")";
  }
  elsif(streq($type,"call")){
    return call_to_str($elem);
  }
  elsif(streq($type,"array")){
    return array_to_str($elem);
  }
  elsif(streq($type,"hash")){
    return hash_to_str($elem);
  }
  elsif(isarray($$elem[1])){
    return expr_to_str($elem);
  }
  halt("unexpected expression element: " . $type);
}
sub fn_to_str{ my ($st,$depth)= @_;
  my $args=[];
  my $i=0;
  while($i<len($$st[2])){
    apush($args,getwdef($spc,"var_start","") . $$st[2][$i][1]);
    $i+=1;
  }
  $args="(" . ajoin(",",$args) . ")";
  my $res=$$spc{"fn_def"} . " " . $$st[1];
  my $block=block_to_str($$st[3],$depth);
  if(!streq($$spc{"lang"},"pl")){
    $res.=$args;
  }
  elsif(!streq($args,"()")){
    my $parts=asplit('\n',$block,2);
    $block=$$parts[0] . " " . $$spc{"var_def"} . " " . $args . "= \@_;\n" . $$parts[1];
  }
  return $res . $block;
}
sub getwdef{ my ($h,$k,$d)= @_;
  if(haskey($k,$h)){
    return $$h{$k};
  }
  return $d;
}
sub hash_to_str{ my ($expr)= @_;
  my $lbr=getwdef($spc,"hash_lit_quote","{");
  my $res=$lbr;
  my $i=1;
  while($i<len($expr)){
    $res.=expr_to_str($$expr[$i]) . getwdef($spc,"hash_arrow","=>") . expr_to_str($$expr[$i+1]) . ",";
    $i+=2;
  }
  return $res . chr(ord($lbr)+2);
}
sub kw1_to_str{ my ($expr)= @_;
  my $res=$$expr[1];
  $res=getwdef($spc,$res,$res);
  $res=getwdef($kw1map,$res,$res);
  if(len($expr)>2){
    $res.=' ' . expr_to_str($$expr[2]);
  }
  return $res;
}
sub lit_to_str{ my ($elem)= @_;
  my $q1='"';
  my $q2=$q1;
  if(!streq($$elem[2],'"')){
    if(streq($$spc{"lang"},"py")){
      $q1=' r"';
    }
    elsif(streq($$spc{"lang"},"js")){
      $q1=" String.raw`";
      $q2="`";
    }
    else{
      $q1="'";
      $q2="'";
    }
  }
  return $q1 . $$elem[1] . $q2;
}
sub repstr{ my ($s,$n)= @_;
  my $res="";
  while($n>0){
    $res.=$s;
    $n-=1;
  }
  return $res;
}
sub stmt_to_str{ my ($st,$depth)= @_;
  if(streq($$st[0],"call")){
    return call_to_str($st);
  }
  elsif(streq($$st[0],"asgn")){
    return asgn_to_str($st);
  }
  elsif(streq($$st[0],"def")){
    return def_to_str($st);
  }
  elsif(streq($$st[0],"defn")){
    return fn_to_str($st,$depth);
  }
  elsif(streq($$st[0],"kw1")){
    return kw1_to_str($st);
  }
  elsif(match($$st[0],"if|elsif|else|while")){
    return cond_to_str($st,$depth);
  }
  return "unknown_statement";
}
sub stlist_to_str{ my ($ast,$depth)= @_;
  my $res="";
  my $i=0;
  while($i<len($ast)){
    my $st=$$ast[$i];
    $res.=repstr(" ",$depth*$indent);
    $res.=stmt_to_str($st,$depth);
    if(!streq($$st[len($st)-1],"blk")){
      $res.=";";
    }
    $res.="\n";
    $i+=1;
  }
  return $res;
}
sub ternary_to_str{ my ($expr)= @_;
  my $cond=expr_to_str($$expr[1]);
  my $yes=expr_to_str($$expr[2]);
  my $no=expr_to_str($$expr[3]);
  if(!streq($$spc{'lang'},'py')){
    return $cond . '?' . $yes . ':' . $no;
  }
  return $yes . ' if ' . $cond . ' else ' . $no;
}
sub var_to_str{ my ($elem)= @_;
  my $res=getwdef($spc,"var_start","") . $$elem[1];
  if(len($elem)>2){
    $res=getwdef($spc,"varx_start","") . $res;
    my $i=2;
    while($i<len($elem)){
      my $quote=$$elem[$i][0];
      if(streq($quote,"{")){
        $quote=getwdef($spc,"hash_idx_quote","[");
      }
      $res.=$quote . expr_to_str($$elem[$i][1]) . chr(ord($quote)+2);
      $i+=1;
    }
  }
  return $res;
}
sub ast_to_str{ my ($ast,$lang,$ind,$noprefix)= @_;
  $indent=$ind;
  $spc=$$specific{$lang};
  $lib=funclib($lang);
  my $libkeys=asort(hkeys($lib));
  my $i=0;
  while($i<len($libkeys)){
    my $fname=$$libkeys[$i];
    if(!isarray($$lib{$fname})){
      $$lib{$fname}=[$$lib{$fname},$fname];
    }
    apush($$lib{$fname},0);
    $i+=1;
  }
  my $prefix=getwdef($spc,"header","");
  my $code=stlist_to_str($ast,0);
  $i=0;
  while($i<len($libkeys)){
    my $fname=$$libkeys[$i];
    if($$lib{$fname}[2]&&!$noprefix){
      $prefix.=$$lib{$fname}[0] . "\n";
    }
    $i+=1;
  }
  return $prefix . $code;
}
