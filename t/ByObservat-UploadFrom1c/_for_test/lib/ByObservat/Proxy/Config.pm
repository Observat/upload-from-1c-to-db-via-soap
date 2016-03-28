package ByObservat::Proxy::Config;

sub get_hash {
  my ( $self, @params ) = @_;

  my $config = {
    'soap_staff_basic_server' => 'soap-test.dev.gstu.by',
    'soap_staff_basic_port' => '8090',
    'soap_staff_basic_uid' => '12',
  };

  return $config;
}

1;
