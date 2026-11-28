function translate() {
  let src = editor.getValue();
  let lang = document.getElementById('lang').value;
  try {
    let ast = to_ast(src);
    let out = ast_to_str(ast, lang, 2, 1);
    document.getElementById('output').value = out;
  } catch(error) {
    document.getElementById('output').value = error.message;
  }
}
function myconsole(...args) {
  document.getElementById('output').value += args.join(' ') + '\n';
}
function runjs() {
  console.log = myconsole;
  document.getElementById('lang').value = 'js';
  translate();
  let out = document.getElementById('output');
  let code = out.value;
  out.value = '';
  eval(code);
}
async function example(name) {
  let resp = await fetch('./tests/' + name + '.ez');
  let data = await resp.text();
  editor.setValue(data);
}
document.getElementById('translatebtn').onclick=translate;
document.getElementById('runjs').onclick=runjs;
ace.define("ace/mode/ez_highlight_rules", function(require, exports, module) {
  var oop = require("ace/lib/oop");
  var textRules = require("ace/mode/text_highlight_rules").TextHighlightRules;
  var ezRules = function() {
    this.$rules = {
      start: [
        {token: "comment", regex: "#.*$"},
        {token: "string.quoted.double", regex: '"', next: "qqstring"},
        {token: "string.quoted.single", regex: "'", next: "qstring"},
        {token: "keyword", regex: /\b(?:def|fn|if|else|elsif|while|for|break|cont|ret)\b/},
        {token: "constant.numeric", regex: /\b\d+\b/},
        {token: "constant.numeric", regex: /\b(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\b/},
        {token: "keyword.operator", regex: /\+=|-=|\*=|\/=|\.=|%=|==|!=|<=|>=|=>|\|\||&&/},
        {token: "paren.lparen", regex: /[\[({]/},
        {token: "paren.rparen", regex: /[\])}]/},
        {token: "punctuation.operator", regex: /[?:,;]/},
        {token: "keyword.operator", regex: /[+\-*/%=<>!.]/},
      ],
      qqstring: [
        {token: "constant.character.escape", regex: /\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|["\\\/bfnrt]|.)/},
        {token: "string.quoted.double", regex: '"', next: "start"},
        {defaultToken: "string.quoted.double"},
      ],
      qstring: [
        {token: "constant.character.escape", regex: /\\(?:[\\']|.)/},
        {token: "string.quoted.single", regex: "'", next: "start"},
        {defaultToken: "string.quoted.single"},
      ],
    };
    this.normalizeRules();
  };
  oop.inherits(ezRules, textRules);
  exports.ezRules = ezRules;
});
ace.define("ace/mode/ez", function(require, exports, module) {
  var oop = require("ace/lib/oop");
  var textMode = require("ace/mode/text").Mode;
  var ezRules = require("ace/mode/ez_highlight_rules").ezRules;
  var mode = function() {this.HighlightRules = ezRules;};
  oop.inherits(mode, textMode);
  (function(){this.$id = "ace/mode/ez";}).call(mode.prototype);
  exports.Mode = mode;
});
var editor = ace.edit("source");
editor.session.setMode("ace/mode/ez")
