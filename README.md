# EZ-code

Attempt to create simplistic scripting language which translates easily
both to Perl (or perhaps PHP in future) for server-side use - and to JS
for use in browser.

This is intended to be used for describing logic of Mud-like game, so that
it can both work on server and be used as a JS sandbox for uses wishing to
create their own parts of the game.

Under development and at the moment without strong feeling that it could be
completed / perfected to be suitable for any practial purpose.

### Usage

Like this:

    perl main.pl sample0.ez

It will convert `sample0.ez` to perl source in-memory and execute it. If the
output file parameter is added, result of conversion is not executed but
rather written to that file:

    perl main.pl sample0.ez result0.pl
