use v5.16;use warnings;
my $lib;
my $spc;
my $indent;
my $specific={"pl"=>{"lang"=>"pl","var_start"=>"\$","varx_start"=>"\$","hash_idx_quote"=>"{","var_def"=>"my","fn_def"=>"sub","break"=>"last","cont"=>"next","header"=>"use v5.16;use warnings;\n",},"js"=>{"lang"=>"js","concat_op"=>"+","hash_arrow"=>":","var_def"=>"let","fn_def"=>"function","elsif"=>"else if",},"php"=>{"lang"=>"php","var_start"=>"\$","hash_lit_quote"=>"[","fn_def"=>"function","elsif"=>"elseif","header"=>"<?php\n",},"py"=>{"lang"=>"py","concat_op"=>"+","&&"=>" and ","||"=>" or ","!"=>" not ","hash_arrow"=>":","fn_def"=>"def","elsif"=>"elif","header"=>"import math\n",},};
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
    $res=":\n" . subst($res,"\\s+\$","");
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
  elsif(streq($type,"num")){
    return $$elem[1];
  }
  elsif(streq($type,"str")){
    return "\"" . $$elem[1] . "\"";
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
    my $parts=asplit("\\n",$block,2);
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
    return subst(getwdef($spc,$$st[1],$$st[1]),"cont","continue");
  }
  elsif(streq($$st[0],"ret")){
    return "return " . expr_to_str($$st[1]);
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
