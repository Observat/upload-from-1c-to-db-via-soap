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

my $record1 = { 'TAB_NOM'=>101, 'FAM'=>'FAM',  'IMY'=>'IMY',  'OTCH'=>'OTCH',  'LIN'=>'321', 'PDR'=>'PDR',  'DLG'=>'DLG',  'TP_ID'=>'200', status=>0 };
my $record2 = { 'TAB_NOM'=>102, 'FAM'=>'FAM2', 'IMY'=>'IMY2', 'OTCH'=>'OTCH2', 'LIN'=>'322', 'PDR'=>'PDR2', 'DLG'=>'DLG2', 'TP_ID'=>'400', status=>1 };

plan tests => 1*scalar(@modules) + (3+1+3+5+4+4+3)*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

foreach my $class ( @classes ) {
  my $object = $class->new();

  ok( defined $object->to->table_name );
  ok( defined $object->to->table_key );
  is_deeply( [ sort @{ $object->to->table_fields} ], [ sort keys %$record1 ] );

  is( $object->to->get_count, 17 );

  is( $object->to->get_record, undef );
  is( $object->to->get_record('13'), undef );
  is( ref $object->to->get_record('12'), 'HASH' );

  is( ref $object->to->get_all_pk, 'ARRAY' );
  is( ref $object->to->get_all_records, 'ARRAY' );
  is( scalar @{ $object->to->get_all_pk }, 17 );
  is( scalar @{ $object->to->get_all_records }, 17 );
  is_deeply( [ sort map { $_->{$object->to->table_key} } @{ $object->to->get_all_records } ], [ sort @{ $object->to->get_all_pk } ] );

  my @arr_for_insert = ( $record1, $record2 );
  is( $object->to->insert_records( \@arr_for_insert ), 2 );
  is( $object->to->get_count, 19 );
  is_deeply( $object->to->get_record( $record1->{ $object->to->table_key } ), $record1 );
  is_deeply( $object->to->get_record( $record2->{ $object->to->table_key } ), $record2 );

  my @arr_for_update = ( $record1, { %$record2, 'DLG' => 'DLG21' } );
  is( $object->to->update_records( \@arr_for_update ), 2 );
  is( $object->to->get_count, 19 );
  is_deeply( $object->to->get_record( $arr_for_update[0]->{ $object->to->table_key } ), $arr_for_update[0] );
  is_deeply( $object->to->get_record( $arr_for_update[1]->{ $object->to->table_key } ), $arr_for_update[1] );

  my @arr_for_delete = ( $record1, $record2 );
  is( $object->to->delete_records( [ map { $_->{ $object->to->table_key } } @arr_for_delete ] ), 2 );
  is( $object->to->get_count, 17 );
  is( $object->to->get_record( $record1->{ $object->to->table_key } ), undef );

#  warn "\n### BEGIN_REPORT:\n". $object->report->result_as_string ."### END_REPORT\n";
}

# Откатываем все изменения в БД:
use FindBin;
my $cmd_restore_db = "perl $FindBin::Bin/01-copy_db_for_test.t";
`$cmd_restore_db`;
