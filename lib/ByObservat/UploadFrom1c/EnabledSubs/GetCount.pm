package ByObservat::UploadFrom1c::EnabledSubs::GetCount;
use parent 'Exporter';
use utf8;

our @EXPORT = qw( getCount );

sub getCount {
  my ( $self ) = @_;
  $self = $self->_init();

  return $self->from->getCount( $self->to->get_count );
}

1;
