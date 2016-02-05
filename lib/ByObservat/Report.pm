package ByObservat::Report;
use Mojo::Base '-base';
use utf8;

has 'module_log';
has 'uid';

# Структура данных: [ [ 'message', 'level' ],  [ 'message2', 'level2' ], ... ]

sub new {
  my ( $self, $uid, $module_log ) = @_;

  $module_log //= 'EsapCommon::Log';  # TODO

  $self = $self->SUPER::new( { uid => $uid, module_log => $module_log } );
  if( ! defined $self->{report} ) {
    $self->{report} = [];
  };

  return $self;
}

sub add {
  my ( $self, $message, $level ) = @_;

  $level //= 'info';

  push @{ $self->{report} }, [ $message, $level ];
}

sub add_log { # TODO error, если в конструкторе не было $uid и $module_log
  my ( $self, $message, $level ) = @_;

  $level //= 'info';

  $self->module_log->add( $message, $level, $self->uid );

  return $self->add( $message, $level );
}

sub result {
  my ( $self ) = @_;

  return $self->{report};
}

sub result_as_string {
  my ( $self ) = @_;

  my @strings = ();
  foreach my $pair ( @{$self->result // []} ) {
    push @strings, $pair->[1]."\t\t".$pair->[0]."\n";
  };

  return join '', @strings;
}

1;
