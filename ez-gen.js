//generated file, don't edit directly
let flib={'pl':{'callname': String.raw`sub callname{(\&{$_[0]})->(@{$_[1]});}`,'eq':['sub streq{$_[0] eq $_[1];}','streq'],'halt':'sub halt{say($_[1]);exit($_[0]);}','haskey':'sub haskey{defined $_[1]->{$_[0]};}','isarray':'sub isarray{ref($_[0]) eq "ARRAY";}','join':['sub ajoin{join $_[0], @{$_[1]}}','ajoin'],'keys':[ String.raw`sub hkeys{my @res = keys(%{$_[0]}); \@res;}`,'hkeys'],'len':'sub len{scalar @{$_[0]};}','match':'sub match{$_[0] =~ qr/$_[1]/;}','pop':['sub apop{pop @{$_[0]};}','apop'],'push':['sub apush{push @{$_[0]}, $_[1];}','apush'],'scmp':'sub scmp{$_[0] cmp $_[1];}','slice': String.raw`sub slice{my @res = @{$_[0]}[$_[1] .. $_[2]];\@res;}`,'shift':['sub ashift{shift @{$_[0]};}','ashift'],'sort':[ String.raw`sub asort{my @res = sort @{$_[0]};\@res;}`,'asort'],'split':[ String.raw`sub asplit{my @res = split($_[0],$_[1],($_[2]//0)); \@res;}`,'asplit'],'subst':'sub subst{$_[0] =~ s/$_[1]/$_[2]/rg;}','unshift':['sub aunshift{unshift @{$_[0]}, $_[1];}','aunshift'],'writeln':'sub writeln{say(@_);}',},'js':{'atan2':'function atan2(a,b){return Math.atan2(a,b)}','callname':'function callname(f,a){return eval(f)(...a);}','eq':'function eq(a,b){return a == b}','halt':'function halt(c,m){throw new Error(m)}','haskey':'function haskey(k,o){return Object.hasOwn(o,k)}','int':'function int(x){return Math.trunc(x)}','isarray':'function isarray(a){return Array.isArray(a)}','join':'function join(sep,a){return a.join(sep)}','keys':['','Object.keys'],'len':'function len(a){return a.length}','match':'function match(s,r){return s.match(new RegExp(r))!==null}','pop':'function pop(a){return a.pop()}','push':'function push(a,x){a.push(x)}','scmp':'function scmp(a,b){return a.localeCompare(b)}','slice':'function slice(a,s,e){return a.slice(s,e+1)}','shift':'function shift(a){return a.shift()}','sort':'function sort(a){return a.toSorted()}','split':'function split(sep,a,lim){if(arguments.length<3)return a.split(new RegExp(sep));let r=[];while(--lim){let m=a.match(sep);r.push(a.slice(0,m.index));a=a.slice(m.index+m[0].length)}r.push(a);return r}','subst':'function subst(a,p,s){return a.replace(new RegExp(p,"g"),s)}','unshift':'function unshift(a,e){a.unshift(e)}','writeln':'function writeln(..._){console.log(_.join(""))}',},'php':{'callname':'function callname($f,$a){return call_user_func($f,...$a);}','eq':'function eq($a,$b){return $a==$b;}','halt': String.raw`function halt($c,$m){echo "$m\n";exit($c);}`,'haskey':['','array_key_exists'],'int':['','intval'],'isarray':'function isarray($a){return is_array($a)&&array_is_list($a);}','join':['','implode'],'keys':['','array_keys'],'len':['','count'],'match':['function smatch($s,$r){return preg_match("/$r/",$s);}','smatch'],'pop':['','array_pop'],'push':['','array_push'],'scmp':['','strcmp'],'slice':['','array_slice'],'shift':['','array_shift'],'sort':['function ipsort($a){$res=$a;sort($res);return $res;}','ipsort'],'split':'function split($sep,$a,$lim=0){return preg_split("/$sep/",$a,$lim);}','subst':'function subst($a,$r,$s){return preg_replace("/$r/",$s,$a);}','unshift':['','array_unshift'],'writeln': String.raw`function writeln(...$args){echo implode("", $args)."\n";}`,},'py':{'atan2':'def atan2(a,b): return math.atan2(a,b)','callname':'def callname(f,a):return eval(f)(*a)','eq':'def eq(a,b):return str(a)==str(b)','halt':'def halt(c,m):print(m);sys.exit(c)','haskey':'def haskey(k,d):return k in d','isarray':'def isarray(a):return isinstance(a,list)','join':'def join(s,a):return s.join([str(x) for x in a])','keys':'def keys(a):return a.keys()','push':'def push(a,x):a.append(x)','match':'def match(s,r):return re.search(r,s)','pop':'def pop(a):return a.pop()','push':'def push(a,x):a.append(x)','scmp':'def scmp(a,b):return (a>b)-(a<b)','slice':'def slice(a,s,e):return a[s:e+1]','shift':'def shift(a):return a.pop(0)','sort':['','sorted'],'split':'def split(r,a,lim=1):return re.split(r,a,lim-1)','subst':'def subst(a,r,s):return re.sub(r,s,a)','unshift':'def unshift(a,x):a.insert(0,x)','writeln':'def writeln(*args): print(*args, sep="")',},};
function funclib(lang){
  return flib[lang];
}
function callname(f,a){return eval(f)(...a);}
function eq(a,b){return a == b}
function halt(c,m){throw new Error(m)}
function haskey(k,o){return Object.hasOwn(o,k)}
function join(sep,a){return a.join(sep)}
function len(a){return a.length}
function match(s,r){return s.match(new RegExp(r))!==null}
function push(a,x){a.push(x)}
function split(sep,a,lim){if(arguments.length<3)return a.split(new RegExp(sep));let r=[];while(--lim){let m=a.match(sep);r.push(a.slice(0,m.index));a=a.slice(m.index+m[0].length)}r.push(a);return r}
function subst(a,p,s){return a.replace(new RegExp(p,"g"),s)}
function unshift(a,e){a.unshift(e)}
let kws={'def':'p_def','fn':'p_defn','while':'p_cond','if':'p_cond','else':'p_cond','elsif':'p_cond','for':'p_cond','ret':'p_onekw','break':'p_onekw','cont':'p_onekw',};
let data;
let cur=0;
let pos=[1,1];
function adv(){
  let c=data[cur];
  cur+=1;
  if(!eq(c,"\n")){
    pos[1]+=1;
  }
  else{
    pos[0]+=1;
    pos[1]=1;
  }
  return c;
}
function peek(){
  return data[cur];
}
function err(msg){
  halt(1,msg+' at '+join(':',pos));
}
function fetch_cmp_op(){
  let op=adv();
  if(match(op, String.raw`[\<\>]`)){
    if(eq(peek(),'=')){
      op+=adv();
    }
    return op;
  }
  if(!eq(adv(),'=')){
    err('unknown comparison operator');
  }
  return op+'=';
}
function fetch_log_op(){
  let op=adv();
  if(!eq(adv(),op)){
    err('unknown logic operator');
  }
  return op+op;
}
function p_array(){
  adv();
  p_space();
  let res=['array'];
  if(!eq(peek(),']')){
    while(1){
      push(res,p_expr());
      p_space();
      let rbr=adv();
      if(eq(rbr,']')){
        break;
      }
      if(!eq(rbr,',')){
        err('expected "]" or "," in array literal');
      }
      p_space();
    }
  }
  else{
    adv();
  }
  return res;
}
function p_asgn(target){
  p_space();
  let op=adv();
  if(!eq(op,'=')){
    if(!match(op, String.raw`[\+\-\*\/%\.]`)||!eq(adv(),'=')){
      err('expected keyword or "=" for assignment');
    }
    op+='=';
  }
  p_space();
  return ['asgn',target,op,p_expr()];
}
function p_assoc(){
  adv();
  p_space();
  let res=['hash'];
  if(!eq(peek(),'}')){
    while(1){
      if(!eq(peek(),'"')&&!eq(peek(),"'")){
        err('expected string for key in hash literal');
      }
      push(res,p_str());
      p_space();
      if(!eq(adv(),':')){
        err('expected ":" after key in hash literal');
      }
      p_space();
      push(res,p_expr());
      p_space();
      let rbr=adv();
      if(eq(rbr,'}')){
        break;
      }
      if(!eq(rbr,',')){
        err('expected "}" or "," in hash literal');
      }
      p_space();
    }
  }
  else{
    adv();
  }
  return res;
}
function p_block(res){
  let startline=pos[0];
  adv();
  push(res,stlist());
  push(res,'blk');
  p_space();
  if(!eq(adv(),'}')){
    err('expected "}" to end block (started around line '+startline+')');
  }
}
function p_call(fname){
  p_space();
  if(!eq(adv(),'(')){
    err('expected "(" for function call');
  }
  let args=[];
  p_space();
  if(!eq(peek(),')')){
    while(1){
      push(args,p_expr());
      p_space();
      let rbr=adv();
      if(eq(rbr,')')){
        break;
      }
      if(!eq(rbr,',')){
        err('expected ")" or "," in argument list');
      }
      p_space();
    }
  }
  else{
    adv();
  }
  return ['call',fname,args];
}
function p_cond(kw,prev){
  let res=[kw];
  if(match(kw,'else|elsif')&&(len(prev)==0||!match(prev[len(prev)-1][0],'if|elsif'))){
    err(kw+' without preceding if');
  }
  p_space();
  if(!eq(kw,'else')){
    if(!eq(adv(),'(')){
      err('expected "(" before condition');
    }
    p_space();
    if(eq(kw,'for')){
      push(res,p_var(p_word()));
      p_space();
      if(!eq(adv(),':')){
        err('expected ":" in for loop');
      }
      p_space();
    }
    push(res,p_expr());
    p_space();
    if(!eq(adv(),')')){
      err('expected ")" after condition');
    }
    p_space();
  }
  if(eq(peek(),'{')){
    p_block(res);
  }
  else{
    push(res,[stmt()]);
  }
  return res;
}
function p_def(){
  p_space();
  let v=p_var(p_word());
  p_space();
  if(eq(peek(),'=')){
    v=p_asgn(v);
  }
  return ['def',v];
}
function p_defn(){
  p_space();
  let name=p_word();
  p_space();
  if(!eq(peek(),'(')){
    err('expected "(" in function definition');
  }
  adv();
  p_space();
  let args=[];
  p_space();
  if(!eq(peek(),')')){
    while(1){
      push(args,p_var(p_word()));
      p_space();
      let rbr=adv();
      if(eq(rbr,')')){
        break;
      }
      if(!eq(rbr,',')){
        err('expected ")" or "," in func arguments');
      }
      p_space();
    }
  }
  else{
    adv();
  }
  p_space();
  if(!eq(adv(),'{')){
    err('expected "{" to start func body');
  }
  let res=['defn',name,args];
  p_block(res);
  return res;
}
function p_expr(){
  let res=p_ex_or();
  p_space();
  if(!eq(peek(),'?')){
    return res;
  }
  adv();
  res=['tern',res];
  p_space();
  push(res,p_expr());
  p_space();
  if(!eq(adv(),':')){
    err('expected ":" in ternary operator');
  }
  p_space();
  push(res,p_expr());
  return res;
}
function p_ex_and(){
  return p_ex_bop('p_ex_cmp','&','fetch_log_op');
}
function p_ex_bop(fnext,expr,fgetop){
  let res=[callname(fnext,[])];
  p_space();
  while(match(peek(),expr)){
    unshift(res,['op',callname(fgetop,[])]);
    p_space();
    push(res,callname(fnext,[]));
    p_space();
  }
  if(len(res)==1){
    return res[0];
  }
  return res;
}
function p_ex_cmp(){
  return p_ex_bop('p_ex_sum', String.raw`[\<\>\!=]`,'fetch_cmp_op');
}
function p_ex_mul(){
  return p_ex_bop('p_value', String.raw`[\*\/%]`,'adv');
}
function p_ex_or(){
  return p_ex_bop('p_ex_and', String.raw`\|`,'fetch_log_op');
}
function p_ex_sum(){
  return p_ex_bop('p_ex_mul', String.raw`[\+\-\.]`,'adv');
}
function p_onekw(w){
  let res=['kw1',w];
  p_space();
  if(eq(w,'ret')&&!eq(peek(),';')){
    push(res,p_expr());
  }
  return res;
}
function p_num(){
  let n='';
  while(match(peek(), String.raw`\d`)){
    n+=adv();
  }
  if(eq(peek(),'.')){
    n+=adv();
    while(match(peek(), String.raw`\d`)){
      n+=adv();
    }
    if(eq(n,'.')){
      err('expected digits before or after decimal point to form number');
    }
  }
  if(eq(peek(),'e')||eq(peek(),'E')){
    n+=adv();
    if(eq(peek(),'+')||eq(peek(),'-')){
      n+=adv();
    }
    if(!match(peek(), String.raw`\d`)){
      err('digit expected in number exponent part');
    }
    while(match(peek(), String.raw`\d`)){
      n+=adv();
    }
  }
  return ['num',n];
}
function p_space(){
  while(match(peek(), String.raw`[\s#]`)){
    if(eq(adv(),'#')){
      while(!eq(peek(),"\n")&&!eq(peek(),"\0")){
        adv();
      }
    }
  }
}
function p_str(){
  let quote=adv();
  let res='';
  let esc=0;
  let start=join(':',pos);
  while(1){
    let c=adv();
    if(eq(c,"\0")){
      err('unterminated string literal starting at '+start);
    }
    if(!esc){
      if(eq(c,quote)){
        break;
      }
      if(eq(c,"\\")){
        esc=1;
      }
    }
    else{
      esc=0;
    }
    res+=c;
  }
  return ['str',res,quote];
}
function p_unary(){
  let op=adv();
  return ['uop',op,p_value()];
}
function p_value(){
  if(match(peek(), String.raw`[A-Za-z\$]`)){
    let name=p_word();
    p_space();
    if(!eq(peek(),'(')){
      return p_var_indexed(name);
    }
    else{
      return p_call(name);
    }
  }
  if(match(peek(), String.raw`[\!\-]`)){
    return p_unary();
  }
  if(match(peek(), String.raw`[\d\.]`)){
    return p_num();
  }
  if(eq(peek(),'"')||eq(peek(),"'")){
    return p_str();
  }
  if(eq(peek(),'[')){
    return p_array();
  }
  if(eq(peek(),'{')){
    return p_assoc();
  }
  if(eq(adv(),'(')){
    let ex=p_expr();
    p_space();
    if(!eq(adv(),')')){
      err('expected ")" to end subexpression');
    }
    return ['brex',ex];
  }
  err('value expected in expression');
}
function p_var(name){
  return ['var',subst(name, String.raw`^\$`,'')];
}
function p_var_indexed(name){
  let v=p_var(name);
  while(match(peek(), String.raw`[\[\{]`)){
    let quote=adv();
    p_space();
    push(v,[quote,p_expr()]);
    p_space();
    quote=chr(ord(quote)+2);
    if(!eq(adv(),quote)){
      err('expected '+quote+' after index expression');
    }
  }
  return v;
}
function p_word(){
  let w=adv();
  while(match(peek(), String.raw`\w`)){
    w+=adv();
  }
  return w;
}
function stmt(prev){
  p_space();
  if(!match(peek(), String.raw`[A-Za-z\$]`)){
    err( String.raw`letter or \'$\' expected at start of statement`);
  }
  let word=p_word();
  if(haskey(word,kws)){
    return callname(kws[word],[word,prev]);
  }
  p_space();
  if(eq(peek(),'(')){
    return p_call(word);
  }
  return p_asgn(p_var_indexed(word));
}
function stlist(){
  let res=[];
  while(1){
    p_space();
    if(eq(peek(),"\0")||eq(peek(),'}')){
      break;
    }
    let st=stmt(res);
    push(res,st);
    p_space();
    if(!eq(st[len(st)-1],'blk')&&!eq(adv(),';')){
      err('expected ";" at the end of statement');
    }
  }
  return res;
}
function to_ast(code){
  cur=0;
  pos=[1,1];
  data=split('',code);
  push(data,"\0");
  let ast=stlist();
  if(!eq(peek(),"\0")){
    err('statement expected');
  }
  return ast;
}
function eq(a,b){return a == b}
function halt(c,m){throw new Error(m)}
function haskey(k,o){return Object.hasOwn(o,k)}
function isarray(a){return Array.isArray(a)}
function join(sep,a){return a.join(sep)}
function len(a){return a.length}
function match(s,r){return s.match(new RegExp(r))!==null}
function push(a,x){a.push(x)}
function slice(a,s,e){return a.slice(s,e+1)}
function sort(a){return a.toSorted()}
function split(sep,a,lim){if(arguments.length<3)return a.split(new RegExp(sep));let r=[];while(--lim){let m=a.match(sep);r.push(a.slice(0,m.index));a=a.slice(m.index+m[0].length)}r.push(a);return r}
function subst(a,p,s){return a.replace(new RegExp(p,"g"),s)}
function unshift(a,e){a.unshift(e)}
let lib;
let spc;
let indent;
let specific={'pl':{'lang':'pl','var_start':'$','varx_start':'$','hash_idx_quote':'{','var_def':'my','fn_def':'sub','break':'last','cont':'next','header':"use v5.16;use warnings;\n",},'js':{'lang':'js','concat_op':'+','hash_arrow':':','var_def':'let','fn_def':'function','elsif':'else if',},'php':{'lang':'php','var_start':'$','hash_lit_quote':'[','fn_def':'function','elsif':'elseif','header':"<?php\n",},'py':{'lang':'py','concat_op':'+','&&':' and ','||':' or ','!':' not ','hash_arrow':':','fn_def':'def','elsif':'elif','header':"import math;import os;import sys;import re\n",},};
let kw1map={'cont':'continue','ret':'return',};
function array_to_str(expr){
  let res=[];
  let i=1;
  while(i<len(expr)){
    push(res,expr_to_str(expr[i]));
    i+=1;
  }
  return '['+join(',',res)+']';
}
function asgn_to_str(expr){
  let op=expr[2];
  if(eq(op,'.=')){
    op=getwdef(spc,'concat_op','.')+'=';
  }
  return expr_to_str(expr[1])+op+expr_to_str(expr[3]);
}
function block_to_str(content,depth){
  let res=stlist_to_str(content,depth+1);
  if(eq(spc['lang'],'py')){
    res=":\n"+subst(res, String.raw`\s+$`,'');
  }
  else{
    res="{\n"+res+repstr(' ',depth*indent)+'}';
  }
  return res;
}
function calc_globals(fnst){
  let vars={};
  for(let a of fnst[2]){
    vars[a[1]]=-1;
  }
  vars=calc_vars(fnst[3],vars);
  let glo=[];
  for(let name of Object.keys(vars)){
    if(vars[name]>0){
      push(glo,name);
    }
  }
  return glo;
}
function calc_vars(arr,vars){
  if(len(arr)==0){
    return vars;
  }
  if(eq(arr[0],'var')){
    let name=arr[1];
    if(!haskey(name,vars)){
      vars[name]=1;
    }
  }
  else if(eq(arr[0],'def')){
    let name=(eq(arr[1][0],'var'))?arr[1][1]:arr[1][1][1];
    vars[name]=-1;
  }
  else{
    for(let x of arr){
      if(isarray(x)){
        vars=calc_vars(x,vars);
      }
    }
  }
  return vars;
}
function call_to_str(expr){
  let name=expr[1];
  let definition=getwdef(lib,name,'');
  if(!eq(definition,'')){
    if(!eq(definition[0],'')){
      definition[2]=1;
    }
    name=definition[1];
  }
  let res=name+'(';
  if(len(expr[2])!=0){
    let i=0;
    while(1){
      res+=expr_to_str(expr[2][i]);
      i+=1;
      if(i>=len(expr[2])){
        break;
      }
      res+=',';
    }
  }
  return res+')';
}
function cond_to_str(st,depth){
  if(!eq(st[len(st)-1],'blk')){
    push(st,'blk');
  }
  let expr=st[0];
  if(eq(expr,'for')){
    expr=for_head_to_str(var_to_str(st[1]),expr_to_str(st[2]));
  }
  else if(!eq(expr,'else')){
    expr=getwdef(spc,expr,expr)+'('+expr_to_str(st[1])+')';
  }
  return expr+block_to_str(st[len(st)-2],depth);
}
function def_to_str(expr){
  let noinit=eq(expr[1][0],'var');
  let kw=getwdef(spc,'var_def','');
  if(eq(kw,'')){
    if(noinit){
      return '';
    }
  }
  else{
    kw+=' ';
  }
  if(noinit){
    return kw+var_to_str(expr[1]);
  }
  return kw+asgn_to_str(expr[1]);
}
function expr_to_str(expr){
  if(!isarray(expr[0])){
    expr=[expr];
  }
  let elem=expr[0];
  let type=elem[0];
  if(eq(type,'op')){
    let a=expr_to_str(slice(expr,1,len(expr)-2));
    let b=expr_to_str([expr[len(expr)-1]]);
    let op=elem[1];
    if(eq(op,'.')){
      op=getwdef(spc,'concat_op',' . ');
      if(eq(spc['lang'],'py')){
        a='str('+a+')';
        b='str('+b+')';
      }
    }
    return a+getwdef(spc,op,op)+b;
  }
  else if(eq(type,'uop')){
    let op=elem[1];
    return getwdef(spc,op,op)+expr_to_str(elem[2]);
  }
  else if(eq(type,'tern')){
    return ternary_to_str(elem);
  }
  else if(eq(type,'num')){
    return elem[1];
  }
  else if(eq(type,'str')){
    return lit_to_str(elem);
  }
  else if(eq(type,'var')){
    return var_to_str(elem);
  }
  else if(eq(type,'brex')){
    return '('+expr_to_str(elem[1])+')';
  }
  else if(eq(type,'call')){
    return call_to_str(elem);
  }
  else if(eq(type,'array')){
    return array_to_str(elem);
  }
  else if(eq(type,'hash')){
    return hash_to_str(elem);
  }
  else if(isarray(elem[1])){
    return expr_to_str(elem);
  }
  halt('unexpected expression element: '+type);
}
function fn_to_str(st,depth){
  let args=[];
  for(let a of st[2]){
    push(args,getwdef(spc,'var_start','')+a[1]);
  }
  let globals=calc_globals(st);
  if(len(globals)>0&&match(spc['lang'],'php|py')){
    unshift(st[3],['global',globals]);
  }
  args='('+join(',',args)+')';
  let res=spc['fn_def']+' '+st[1];
  let block=block_to_str(st[3],depth);
  if(!eq(spc['lang'],'pl')){
    res+=args;
  }
  else if(!eq(args,'()')){
    let parts=split( String.raw`\n`,block,2);
    block=parts[0]+' '+spc['var_def']+' '+args+"= \@_;\n"+parts[1];
  }
  return res+block;
}
function for_head_to_str(v,expr){
  let lang=spc['lang'];
  if(eq(lang,'pl')){
    return 'for my '+v+' (@{'+expr+'})';
  }
  else if(eq(lang,'js')){
    return 'for(let '+v+' of '+expr+')';
  }
  else if(eq(lang,'php')){
    return 'foreach('+expr+' as '+v+')';
  }
  return 'for '+v+' in '+expr;
}
function getwdef(h,k,d){
  if(haskey(k,h)){
    return h[k];
  }
  return d;
}
function globals_to_str(names){
  let vs=getwdef(spc,'var_start','');
  return 'global '+vs+join(','+vs,names);
}
function hash_to_str(expr){
  let lbr=getwdef(spc,'hash_lit_quote','{');
  let res=lbr;
  let i=1;
  while(i<len(expr)){
    res+=expr_to_str(expr[i])+getwdef(spc,'hash_arrow','=>')+expr_to_str(expr[i+1])+',';
    i+=2;
  }
  return res+chr(ord(lbr)+2);
}
function kw1_to_str(expr){
  let res=expr[1];
  res=getwdef(spc,res,res);
  res=getwdef(kw1map,res,res);
  if(len(expr)>2){
    res+=' '+expr_to_str(expr[2]);
  }
  return res;
}
function lit_to_str(elem){
  let q1='"';
  let q2=q1;
  if(eq(elem[2],"'")){
    let backslashed=match(elem[1], String.raw`\\\\`);
    if(eq(spc['lang'],'py')&&backslashed){
      q1=' r"';
    }
    else if(eq(spc['lang'],'js')&&backslashed){
      q1=' String.raw`';
      q2='`';
    }
    else{
      q1="'";
      q2="'";
    }
  }
  return q1+elem[1]+q2;
}
function repstr(s,n){
  let res='';
  while(n>0){
    res+=s;
    n-=1;
  }
  return res;
}
function stmt_to_str(st,depth){
  if(eq(st[0],'call')){
    return call_to_str(st);
  }
  else if(eq(st[0],'asgn')){
    return asgn_to_str(st);
  }
  else if(eq(st[0],'def')){
    return def_to_str(st);
  }
  else if(eq(st[0],'defn')){
    return fn_to_str(st,depth);
  }
  else if(eq(st[0],'kw1')){
    return kw1_to_str(st);
  }
  else if(match(st[0],'if|elsif|else|while|for')){
    return cond_to_str(st,depth);
  }
  else if(eq(st[0],'global')){
    return globals_to_str(st[1]);
  }
  return 'unknown_statement';
}
function stlist_to_str(ast,depth){
  let res='';
  for(let st of ast){
    let ststr=stmt_to_str(st,depth);
    if(eq(ststr,'')){
      continue;
    }
    res+=repstr(' ',depth*indent)+ststr;
    if(!eq(st[len(st)-1],'blk')){
      res+=';';
    }
    res+="\n";
  }
  return res;
}
function ternary_to_str(expr){
  let cond=expr_to_str(expr[1]);
  let yes=expr_to_str(expr[2]);
  let no=expr_to_str(expr[3]);
  if(!eq(spc['lang'],'py')){
    return cond+'?'+yes+':'+no;
  }
  return yes+' if '+cond+' else '+no;
}
function var_to_str(elem){
  let res=getwdef(spc,'var_start','')+elem[1];
  if(len(elem)>2){
    res=getwdef(spc,'varx_start','')+res;
    let i=2;
    while(i<len(elem)){
      let quote=elem[i][0];
      if(eq(quote,'{')){
        quote=getwdef(spc,'hash_idx_quote','[');
      }
      res+=quote+expr_to_str(elem[i][1])+chr(ord(quote)+2);
      i+=1;
    }
  }
  return res;
}
function ast_to_str(ast,lang,ind,noprefix){
  indent=ind;
  spc=specific[lang];
  lib=funclib(lang);
  let libkeys=sort(Object.keys(lib));
  for(let fname of libkeys){
    if(!isarray(lib[fname])){
      lib[fname]=[lib[fname],fname];
    }
    push(lib[fname],0);
  }
  let prefix=getwdef(spc,'header','');
  let code=stlist_to_str(ast,0);
  for(let fname of libkeys){
    if(lib[fname][2]&&!noprefix){
      prefix+=lib[fname][0]+"\n";
    }
  }
  return prefix+code;
}
