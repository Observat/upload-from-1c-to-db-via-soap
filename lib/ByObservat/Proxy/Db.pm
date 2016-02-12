package ByObservat::Proxy::Db;
use EsapCommon::DB;

sub get_dbh {
  shift @_;
  EsapCommon::DB->get_dbh(@_);
}

1;
