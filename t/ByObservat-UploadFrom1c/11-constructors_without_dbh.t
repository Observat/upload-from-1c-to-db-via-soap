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

plan tests => 1*scalar(@modules) + 3*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

foreach my $class ( @classes ) {
  my $object = $class->new();
  ok( defined $object );
  is( ref $object, $class );
  ok( $object->getCount );
}
