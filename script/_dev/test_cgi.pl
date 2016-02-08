#!/usr/bin/env perl
use utf8;
use open qw/:std :utf8/;

print "Content-type: text/html\n\n";
print "<html><body>Hello, world. Сейчас ".localtime.".</body></html>";
