package ByObservat::Proxy::Log;
use EsapCommon::Log;

sub add {
  shift @_;
  EsapCommon::Log->add(@_);
}

sub email {
  shift @_;
  EsapCommon::Log->email(@_);
}

1;
