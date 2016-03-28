#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

my @modules = qw(
  GstuSoap::StaffBasic
);

my @classes = qw(
  GstuSoap::StaffBasic
);

plan tests => 1*scalar(@modules) + 1*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

foreach my $class ( @classes ) {
  ok( $class->getCount );
}
