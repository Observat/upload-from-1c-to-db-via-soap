package ByObservat::Proxy::Db;
use DBI;

sub get_dbh {
  my @dbi_connect = ( 'dbi:mysql:soap_test;host=esap.dev.gstu.by', 'test_user', 'test_user', { mysql_enable_utf8 => 1, RaiseError => 0 } );
  return DBI->connect( @dbi_connect );
}

1;
