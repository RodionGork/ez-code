# EZ-code

Attempt to create simplistic scripting language which translates easily
to `Perl`, `PHP` or `Python` for server-side use - and to `JavaScript` for
use in browser.

This is intended to be used for describing logic of Mud-like game, so that
it can both work on server and be used as a JS sandbox for uses wishing to
create their own parts of the game.

Under development and at the moment without strong feeling that it could be
completed / perfected to be suitable for any practial purpose.

### Syntax

We want the language to resemble other C-like languages, so it is similar to
JavaScript, Perl and PHP (a kind of blend). Detailed description is to be
provided yet, but for now here is an example (and others could be found `tests`):

```
# calculates first prime numbers and prints the last generated

def target = 20;             # wanted amount of primes
def primes = [2, 3, 5, 7];

def is_prime(x, divisors) {
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

Language flag could be one of `-pl`, `-js`, `-php`, `-py` and `-ast`. The latter
actually dumps JSON abstract syntax tree without converting it further to
output language. The `-pl` is default and is useful if output file name has
non-standard extension.
