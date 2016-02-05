package ByObservat::UploadFrom1c::From::Soap;
use Mojo::Base '-base';
use utf8;

use SOAP::Lite;

has 'main_object';

sub report { return $_[0]->main_object->report; }

sub _fault {
  my ( $self, $message ) = @_;

  eval { $self->report->add_log( $message, 'warning') }; # TODO warning or error ?
  die SOAP::Fault->new()->faultcode('Server.Custom')->faultstring( $message );
}

sub getCount {
  my ( $self, $count ) = @_;

  my $result_eval = eval {
    die unless defined $count; # TODO  $@ eq 'Died'?
    SOAP::Data->name('result')->type('int')->value( $count );
  };

  if( $@ ) {
    return $self->_fault( "Ошибка при получении количества записей ".ref( $self ).". $@" );
  }
  else {
    return $result_eval;
  };
}

sub insertRecords {
  my ( $self, $count_ok, $count_must ) = @_;

  $count_ok //= 0;

  my $result_eval = eval {
    die unless( $count_ok == $count_must ); # TODO  $@ eq 'Died'?
    SOAP::Data->name('result')->type('int')->value( $count_ok );
  };

  if( $@ ) {
    return $self->_fault( "Ошибка при вставке выгруженных из 1C записей: $@" );
  }
  else {
    return $result_eval;
  };
}

sub updateAllRecords {
  my ( $self, $result_hash ) = @_;

  my @result_arr = ();
  foreach( qw/insert update delete skip/ ) {
    push @result_arr, SOAP::Data->name($_)->type('int')->value( $result_hash->{$_} );
  };
  push @result_arr, SOAP::Data->name('message')->type('string')->value( $result_hash->{'message'} );

  my $result_eval = eval {
    SOAP::Data->name('result' => \SOAP::Data->value( @result_arr ) );
  };

  if( $@ ) {
    return $self->_fault( "Ошибка при выгрузке-обновлении ".ref( $self )." из 1C: $@" );
  }
  else {
    return $result_eval;
  };
}

sub updateWithoutDeletingRecords { shift->updateAllRecords( @_ ); }

1;
