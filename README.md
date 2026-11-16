# EZ-code

Attempt to create simplistic scripting language which translates easily
to `Perl` or `PHP` for server-side use - and to `JavaScript` for use in browser.

This is intended to be used for describing logic of Mud-like game, so that
it can both work on server and be used as a JS sandbox for uses wishing to
create their own parts of the game.

Under development and at the moment without strong feeling that it could be
completed / perfected to be suitable for any practial purpose.

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

Language flag could be one of `-pl`, `-js`, `-php` and `-ast`. The latter
actually dumps JSON abstract syntax tree without converting it further to
output language. The `-pl` is default and is useful if output file name has
non-standard extension.
