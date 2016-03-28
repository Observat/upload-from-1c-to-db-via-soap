#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

plan tests => 1;

ok( `wget http://soap-test.dev.gstu.by:8090/StaffBasic 2>&1 1>/dev/null` =~ /411 Length Required/ );
