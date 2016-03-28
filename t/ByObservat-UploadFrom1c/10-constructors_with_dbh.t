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

plan tests => 1*scalar(@modules) + 1 + 3*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

my $dbh = ByObservat::Proxy::Db->get_dbh();
ok( defined $dbh );

foreach my $class ( @classes ) {
  my $object = $class->new( { dbh => $dbh } );
  ok( defined $object );
  is( ref $object, $class );
  ok( $object->getCount );
}

$dbh->disconnect;
