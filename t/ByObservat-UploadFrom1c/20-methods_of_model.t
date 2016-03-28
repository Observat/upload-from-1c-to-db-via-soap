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

my $record1 = { 'TAB_NOM'=>101, 'FAM'=>'FAM',  'IMY'=>'IMY',  'OTCH'=>'OTCH',  'LIN'=>'321', 'PDR'=>'PDR',  'DLG'=>'DLG' };
my $record2 = { 'TAB_NOM'=>102, 'FAM'=>'FAM2', 'IMY'=>'IMY2', 'OTCH'=>'OTCH2', 'LIN'=>'322', 'PDR'=>'PDR2', 'DLG'=>'DLG2', 'TP_ID'=>'400', status=>1 };

plan tests => 1*scalar(@modules) + (2+1+8+8+7)*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

foreach my $class ( @classes ) {
  my $object = $class->new();
  my $base_records = $object->to->get_all_records;

  is( ref $object->getCount, 'SOAP::Data' );
  is( $object->getCount->value, 17 );

  is( ref( $object->split_by_actions([]) ), 'HASH' );

  is( scalar @{ $object->split_by_actions( [] )->{ 'insert' } }, 0 );
  is( scalar @{ $object->split_by_actions( [] )->{ 'update' } }, 0 );
  is( scalar @{ $object->split_by_actions( [] )->{ 'delete' } }, 17 );
  is( scalar @{ $object->split_by_actions( [] )->{ 'skip' } }, 0 );
  is( scalar @{ $object->split_by_actions( $base_records )->{ 'insert' } }, 0 );
  is( scalar @{ $object->split_by_actions( $base_records )->{ 'update' } }, 0 );
  is( scalar @{ $object->split_by_actions( $base_records )->{ 'delete' } }, 0 );
  is( scalar @{ $object->split_by_actions( $base_records )->{ 'skip' } }, 17 );

  my @unload1 = ( $record1, $record2, @$base_records );
  my @unload2 = ( $record1, { %$record2, 'DLG' => 'DLG21' }, @$base_records );
  my @unload3 = ( { %$record1, $object->to->table_key => '104' }, @$base_records );
  my @unload4 = ( { %$record1, $object->to->table_key => '104', 'LIN' => '333' }, @$base_records );
  my @unload5 = ( { %$record1, $object->to->table_key => '104', 'LIN' => '333', status=>1 }, @$base_records );
  my @unload9 = ( $record1, $record2 );

  is( scalar @{ $object->split_by_actions( \@unload1 )->{ 'insert' } }, 2 );
  is( scalar @{ $object->split_by_actions( \@unload1 )->{ 'update' } }, 0 );
  is( scalar @{ $object->split_by_actions( \@unload1 )->{ 'delete' } }, 0 );
  is( scalar @{ $object->split_by_actions( \@unload1 )->{ 'skip' } }, 17 );
  is( scalar @{ $object->split_by_actions( \@unload9 )->{ 'insert' } }, 2 );
  is( scalar @{ $object->split_by_actions( \@unload9 )->{ 'update' } }, 0 );
  is( scalar @{ $object->split_by_actions( \@unload9 )->{ 'delete' } }, 17 );
  is( scalar @{ $object->split_by_actions( \@unload9 )->{ 'skip' } }, 0 );

  is_deeply( $object->update_records( \@unload1 ),
             { 'insert' => 2, 'update' => 0, 'delete' => 0, 'skip' => 17, 'expected' => { 'insert' => 2, 'update' => 0, 'delete' => 0, 'skip' => 17 } } );
  is_deeply( $object->update_records( \@unload2 ),
             { 'insert' => 0, 'update' => 1, 'delete' => 0, 'skip' => 18, 'expected' => { 'insert' => 0, 'update' => 1, 'delete' => 0, 'skip' => 18 } },  );
  # Тест "unload3" намерено вызван с ошибкой: expected_insert == 1, а insert == 0
  is_deeply( $object->update_records( \@unload3 ),
             { 'insert' => 0, 'update' => 0, 'delete' => 2, 'skip' => 17, 'expected' => { 'insert' => 1, 'update' => 0, 'delete' => 2, 'skip' => 17 } } );
  is_deeply( $object->update_records( \@unload4 ),
             { 'insert' => 1, 'update' => 0, 'delete' => 0, 'skip' => 17, 'expected' => { 'insert' => 1, 'update' => 0, 'delete' => 0, 'skip' => 17 } } );
  is_deeply( $object->update_records( \@unload5 ),
             { 'insert' => 0, 'update' => 1, 'delete' => 0, 'skip' => 17, 'expected' => { 'insert' => 0, 'update' => 1, 'delete' => 0, 'skip' => 17 } } );
  is_deeply( $object->update_without_deleting_records( \@unload9 ),
             { 'insert' => 2, 'update' => 0, 'delete' => 0, 'skip' => 0, 'expected' => { 'insert' => 2, 'update' => 0, 'delete' => 18, 'skip' => 0 } } );
  is_deeply( $object->update_records( \@unload9 ),
             { 'insert' => 0, 'update' => 0, 'delete' => 18, 'skip' => 2, 'expected' => { 'insert' => 0, 'update' => 0, 'delete' => 18, 'skip' => 2 } } );

#  warn "\n### BEGIN_REPORT:\n". $object->report->result_as_string ."### END_REPORT\n";
}

# Откатываем все изменения в БД:
use FindBin;
my $cmd_restore_db = "perl $FindBin::Bin/01-copy_db_for_test.t";
`$cmd_restore_db`;
