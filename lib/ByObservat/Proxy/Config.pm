package ByObservat::Proxy::Config;
use EsapCommon::Config;

sub get_hash {
  shift @_;
  EsapCommon::Config->get_hash(@_);
}

1;
