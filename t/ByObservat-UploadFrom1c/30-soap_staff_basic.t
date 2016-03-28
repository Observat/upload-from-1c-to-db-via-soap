#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw/:std :utf8/;
use Test::More;
use SOAP::Lite;
#use SOAP::Lite +trace => [ qw(all -objects) ];
use FindBin;

my $record1 = SOAP::Data->name('StaffBasicElement')->type('StaffBasicElementType')->value(
    \SOAP::Data->value(
      SOAP::Data->name('TAB_NOM')->type('string')->value( '101' ),
      SOAP::Data->name('FAM')->type('string')->value( 'Фамилия' ),
      SOAP::Data->name('IMY')->type('string')->value( 'Имя' ),
      SOAP::Data->name('OTCH')->type('string')->value( 'Отчество' ),
      SOAP::Data->name('PDR')->type('string')->value( 'ЦИТ' ),
      SOAP::Data->name('DLG')->type('string')->value( 'Программист' ),
      SOAP::Data->name('LIN')->type('string')->value( '4160433C060PB8' ),
      SOAP::Data->name('TP_ID')->type('string')->value( '200' ),
      SOAP::Data->name('status')->type('string')->value( '1' ),
    ),
  );
my $record1_min = SOAP::Data->name('StaffBasicElement')->type('StaffBasicElementType')->value(
    \SOAP::Data->value(
      SOAP::Data->name('TAB_NOM')->type('string')->value( '101' ),
      SOAP::Data->name('FAM')->type('string')->value( 'Фамилия' ),
      SOAP::Data->name('IMY')->type('string')->value( 'Имя' ),
      SOAP::Data->name('OTCH')->type('string')->value( 'Отчество' ),
      SOAP::Data->name('PDR')->type('string')->value( 'ЦИТ' ),
      SOAP::Data->name('DLG')->type('string')->value( 'Программист' ),
      SOAP::Data->name('LIN')->type('string')->value( '4160433C060PB8' ),
    ),
  );
my $record2 = SOAP::Data->name('StaffBasicElement')->type('StaffBasicElementType')->value(
    \SOAP::Data->value(
      SOAP::Data->name('TAB_NOM')->type('string')->value( '102' ),
      SOAP::Data->name('FAM')->type('string')->value( 'Фамилия2' ),
      SOAP::Data->name('IMY')->type('string')->value( 'Имя2' ),
      SOAP::Data->name('OTCH')->type('string')->value( 'Отчество2' ),
      SOAP::Data->name('PDR')->type('string')->value( 'ЗФ' ),
      SOAP::Data->name('DLG')->type('string')->value( 'Старший преподаватель' ),
      SOAP::Data->name('LIN')->type('string')->value( '4110483C060PB8' ),
      SOAP::Data->name('TP_ID')->type('string')->value( '200' ),
      SOAP::Data->name('status')->type('string')->value( '1' ),
    ),
  );
my $record2_1 = SOAP::Data->name('StaffBasicElement')->type('StaffBasicElementType')->value(
    \SOAP::Data->value(
      SOAP::Data->name('TAB_NOM')->type('string')->value( '102' ),
      SOAP::Data->name('FAM')->type('string')->value( 'Фамилия2' ),
      SOAP::Data->name('IMY')->type('string')->value( 'Имя2' ),
      SOAP::Data->name('OTCH')->type('string')->value( 'Отчество2_1' ),
      SOAP::Data->name('PDR')->type('string')->value( 'ЗФ' ),
      SOAP::Data->name('DLG')->type('string')->value( 'Старший преподаватель' ),
      SOAP::Data->name('LIN')->type('string')->value( '4111183C060PB8' ),
      SOAP::Data->name('TP_ID')->type('string')->value( '200' ),
      SOAP::Data->name('status')->type('string')->value( '1' ),
    ),
  );
my $record2_fail = SOAP::Data->name('StaffBasicElement')->type('StaffBasicElementType')->value(
    \SOAP::Data->value(
      SOAP::Data->name('TAB_NOM')->type('string')->value( '102' ),
      SOAP::Data->name('FAM')->type('string')->value( 'Фамилия2' ),
      SOAP::Data->name('IMY')->type('string')->value( 'Имя2' ),
      SOAP::Data->name('OTCH')->type('string')->value( 'Отчество2_1' ),
      SOAP::Data->name('PDR')->type('string')->value( 'ЗФ' ),
      SOAP::Data->name('DLG')->type('string')->value( 'Старший преподаватель' ),
      SOAP::Data->name('LIN')->type('string')->value( '4160433C060PB8' ), # fail: exists in $record1
      SOAP::Data->name('TP_ID')->type('string')->value( '200' ),
      SOAP::Data->name('status')->type('string')->value( '1' ),
    ),
  );

my @modules = qw(
  GstuSoap::StaffBasic
);

my @classes = qw(
  GstuSoap::StaffBasic
);

plan tests => 1*scalar(@modules) + (1+5+3+9)*scalar( @classes );

foreach( @modules ) {
  use_ok( $_ );
}

foreach my $class ( @classes ) {
  my $object = $class->new( { 'init_wsdl' => 1 } );

  my $class_wsdl = $object->wsdl->class;
  my $soap_config = ByObservat::Proxy::Config->get_hash(qw/ soap_staff_basic_server soap_staff_basic_port/);

  my $service_uri = 'http://'.$soap_config->{soap_staff_basic_server}.':'.$soap_config->{soap_staff_basic_port}.'/'.$class_wsdl.'.wsdl';
  my $proxy =       'http://'.$soap_config->{soap_staff_basic_server}.':'.$soap_config->{soap_staff_basic_port}.'/'.$class_wsdl;
  my $ns =          'http://'.$soap_config->{soap_staff_basic_server}.':'.$soap_config->{soap_staff_basic_port}.'/'.$class_wsdl;

  SKIP: {
    skip "Not configured soap-server for test", (5+3+5) unless ok( `wget $proxy 2>&1 1>/dev/null` =~ /411 Length Required/ );

    my $client = SOAP::Lite->new( service => $service_uri, default_ns => $ns, proxy => $proxy );
#	$client->autotype(0)->on_action( sub { join '#', @_ } );
    my $som = undef;

    is( ref $object->getCount, 'SOAP::Data' );
    is( ref $client->call("getCount"), 'SOAP::SOM' );
    is( $client->call("getCount")->result, 17 );
    is( $client->call("getCount")->fault, undef );
    is( $client->call("getCount")->faultstring, undef );

    is( ref $client->call("getCount2"), 'SOAP::SOM' );
    is( $client->call("getCount2")->result, undef );
    is( ref $client->call("getCount2")->fault, 'HASH' );

    my @messages_debug = ();

    my $result_update1 = $client->call("updateWithoutDeletingRecords", $record1 )->result;
    push @messages_debug, delete $result_update1->{'message'};
    is_deeply( $result_update1, { 'insert' => 1, 'update' => 0, 'delete' => 0, 'skip' => 0 } );

    my $result_update2 = $client->call("updateAllRecords", $record1, $record2 )->result;
    push @messages_debug, delete $result_update2->{'message'};
    is_deeply( $result_update2, { 'insert' => 1, 'update' => 0, 'delete' => 17, 'skip' => 1 } );

    my $result_update3 = $client->call("updateAllRecords", $record1, $record2 )->result;
    push @messages_debug, delete $result_update3->{'message'};
    is_deeply( $result_update3, { 'insert' => 0, 'update' => 0, 'delete' => 0, 'skip' => 2 } );

    my $result_update4 = $client->call("updateAllRecords", $record1, $record2_1 )->result;
    push @messages_debug, delete $result_update4->{'message'};
    is_deeply( $result_update4, { 'insert' => 0, 'update' => 1, 'delete' => 0, 'skip' => 1 } );

    my $result_update5 = $client->call("updateAllRecords", $record1, $record2_fail )->result;
    push @messages_debug, delete $result_update5->{'message'};
    is_deeply( $result_update5, { 'insert' => 0, 'update' => 0, 'delete' => 0, 'skip' => 1 } );

    my $result_update6 = $client->call("updateAllRecords", $record1_min )->result;
    push @messages_debug, delete $result_update6->{'message'};
    is_deeply( $result_update6, { 'insert' => 0, 'update' => 1, 'delete' => 1, 'skip' => 0 } );

    my $result_update7 = $client->call("updateAllRecords", $record1_min )->result;
    push @messages_debug, delete $result_update7->{'message'};
    is_deeply( $result_update7, { 'insert' => 0, 'update' => 0, 'delete' => 0, 'skip' => 1 } );

    my $result_update8 = $client->call("updateAllRecords", $record1 )->result;
    push @messages_debug, delete $result_update8->{'message'};
    is_deeply( $result_update8, { 'insert' => 0, 'update' => 1, 'delete' => 0, 'skip' => 0 } );

    my $result_update9 = $client->call("updateAllRecords", $record1 )->result;
    push @messages_debug, delete $result_update9->{'message'};
    is_deeply( $result_update9, { 'insert' => 0, 'update' => 0, 'delete' => 0, 'skip' => 1 } );

#    warn $messages_debug[7];
  }; # end SKIP
}

# Откатываем все изменения в БД:
my $cmd_restore_db = "perl $FindBin::Bin/01-copy_db_for_test.t";
`$cmd_restore_db`;
