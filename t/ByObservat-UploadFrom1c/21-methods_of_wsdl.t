#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw/:std :utf8/;

use Test::More;

my @modules = qw(
  GstuSoap::StaffBasic
);

my @classes = qw(
  GstuSoap::StaffBasic
);

plan tests => 1*scalar(@modules) + (5+3)*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

foreach my $class ( @classes ) {
  my $object_null = $class->new();
  my $object = $class->new( { 'init_wsdl' => 1 } );

  is( $object_null->wsdl, undef );
  is( ref $object->wsdl, 'ByObservat::UploadFrom1c::Wsdl' );
  ok( defined $object->wsdl->class );
  ok( defined $object->wsdl->methods );
  is( ref $object->wsdl->methods, 'ARRAY' );

  ok( defined $object->get_wsdl_Service );
  ok( defined $object->get_wsdl_Types );
  ok( defined $object->get_wsdl_ElementType );
}

# Откатываем все изменения в БД:
use FindBin;
my $cmd_restore_db = "perl $FindBin::Bin/01-copy_db_for_test.t";
`$cmd_restore_db`;
