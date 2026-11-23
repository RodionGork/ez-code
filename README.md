# EZ-code

Attempt to create simplistic scripting language which translates easily
to `Perl`, `PHP` or `Python` for server-side use - and to `JavaScript` for
use in browser.

This is intended to be used for describing logic of Mud-like game, so that
it can both work on server and be used as a JS sandbox for uses wishing to
create their own parts of the game.

Under development and at the moment without strong feeling that it could be
completed / perfected to be suitable for any practial purpose.

**Rewritten mostly in itself** - sources of this translator mainly are in
`*.ez` files from now on (particularly `ez2ast.ez` parses code to AST while
`ast2out.ez` converts AST to target language) - while `build.sh` file allows
to generate converted and unified translator "core" in Perl, which is included
in short `main.pl`.

### Syntax

We want the language to resemble other C-like languages, so it is similar to
JavaScript, Perl and PHP (a kind of blend).

- `def x;` is a variable definition
- `def x = ...;` the same with initialization
- `fn myfunc(a, b, c) {...}` - function definition
- `if`, `else`, `elsif`, `while`, `ret` (return), `break`, `cont` (continue) - typical keywords
- `[3, 1, 4, "pi", ...]` - array literal (e.g. for initializing variable)
- `{"number":314, "name":"pi", "arr":[1,2,3]}` - hash literal (e.g. associative array)
- `a{"bla"}[2]` - example of indexing a variable which contains hash of arrays (use curly brackets to index hash, square for array)
- `"two\nlines"` - double-quoted string respects escape sequences and variable interpolation (in languages that support it)
- `'single\nline'` - single-quoted string is either "raw" or close to it (slightly depends on language)

Detailed description is to be provided yet, but for now here is an example
(and others could be found `tests`):

```
# calculates first prime numbers and prints the last generated

def target = 20;             # wanted amount of primes
def primes = [2, 3, 5, 7];

fn is_prime(x, divisors) {
    def i = 0;
    while (1) {
        def d = divisors[i];
        if (d*d > x)
            ret 1;
        if (x % d == 0)
            ret 0;
        i += 1;
    }
}

def n = 9;
while (1) {
    if (is_prime(n, primes)) {
        push(primes, n);
        if (len(primes) == target) {
            writeln("primes[" . target . "] = " . primes[target-1]);
            break;
        }
    }
    n += 2;
}
```

### Usage

Like this:

    perl main.pl tests/t03-collatz.ez -run

It will convert `t03-collatz.ez` to perl source in-memory and execute it. If the
output file parameter is added, result of conversion is not executed but
rather written to that file:

    perl main.pl tests/t03-collatz.ez collatz.pl

Desired language is detected from the output file extension.

To print output to console don't specify file name, but add the desired language
flag:

    perl main.pl tests/t03-collatz.ez -js

This could be then redirected to chosen interpreter (to "run on the fly"):

    perl main.pl tests/t03-collatz.ez -js | node

Language flag could be one of `-pl`, `-js`, `-php`, `-py` and `-ast`. The latter
actually dumps JSON abstract syntax tree without converting it further to
output language. The `-pl` is default and is useful if output file name has
non-standard extension.
