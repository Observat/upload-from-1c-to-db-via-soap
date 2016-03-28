package ByObservat::UploadFrom1c;
use Mojo::Base '-base';
use utf8;

use ByObservat::Report;
use ByObservat::UploadFrom1c::From::Soap;
use ByObservat::UploadFrom1c::To::Dbi;
use ByObservat::UploadFrom1c::Wsdl;

has 'uid';
has 'report';

has 'from';
has 'to';
has 'wsdl';

sub new {
  my ( $self, $params ) = @_;

  my $param_init_wsdl = delete $params->{init_wsdl};
  my $param_wsdl = delete $params->{wsdl};

  $self = $self->SUPER::new( $params );

  $self->report( ByObservat::Report->new( $self->uid ) ) unless defined $self->report;
  $self->from( ByObservat::UploadFrom1c::From::Soap->new( { 'main_object' => $self, %{ $params->{'from'} // {} } } ) );
  $self->to( ByObservat::UploadFrom1c::To::Dbi->new( { 'main_object' => $self, %{ $params->{'to'} // {} } } ) );

  if( $param_init_wsdl and $param_wsdl ) {
    $self->wsdl( ByObservat::UploadFrom1c::Wsdl->new( $param_wsdl) );
  }

  return $self;
}

sub _init {
  my ( $self, $params ) = @_;

  $self = $self->new( $params ) unless ref $self;

  return $self;
}

sub split_by_actions {
  my ( $self, $data ) = @_;

  my $result = { 'insert' => [], 'update' => [], 'delete' => [] };

  my @db_pk = @{ $self->to->get_all_pk };
  my %data_pk = map { $_->{ $self->to->table_key } => $_ } @$data;
  # TODO Залогировать дубли в @$data

  my %hash_spliting = ();
  foreach( @db_pk ) {
    $hash_spliting{$_} += 1;
  };
  foreach( keys %data_pk ) {
    $hash_spliting{$_} += 2;
  };

  foreach( keys %hash_spliting ) {
    if( $hash_spliting{$_} == 1 ) {
      push @{$result->{'delete'}}, $_;
    }
    elsif( $hash_spliting{$_} == 2 ) {
      push @{$result->{'insert'}}, $data_pk{$_};
    }
    else {
      push @{$result->{'update'}}, $data_pk{$_};
    }
  }

  my $result_skip = $self->_split_by_skip( $result->{'update'} );
  $result->{'update'} = $result_skip->{'update'};
  $result->{'skip'} = $result_skip->{'skip'};

  return $result;
}

sub _split_by_skip {
  my ( $self, $data ) = @_;

  my $result = { 'skip' => [], 'update' => [] };

  foreach my $data_row ( @$data ) {
    my $compare_bool = 1;

    my $row_new = { %$data_row };
    my $row_old = $self->to->get_record( $row_new->{$self->to->table_key} );

    foreach( @{$self->to->table_fields} ) {
      if( ( $row_old->{$_}//'') eq ($row_new->{$_}//'') ) {
        delete $row_old->{$_};
        delete $row_new->{$_};
      }
      else {
        $compare_bool = 0;
        last;
      }
    }

    if( $compare_bool and scalar( keys %$row_old ) == 0 and scalar( keys %$row_new ) == 0 ) {
      push @{$result->{'skip'}}, $data_row;
    }
    else {
      push @{$result->{'update'}}, $data_row;
    }
  };

  return $result;
}

sub update_records {
  my ( $self, $data, $params ) = @_;
  $self = $self->_init();
  $params //= {};

  my $data_split = $self->split_by_actions( $data );
  my $result_split = { 'insert' => 0, 'update' => 0, 'delete' => 0, 'skip' => 0 };

  if( scalar @{ $data_split->{'insert'} } ) {
    $result_split->{'insert'} = $self->to->insert_records( $data_split->{'insert'} );
  };
  if( scalar @{ $data_split->{'update'} } ) {
    $result_split->{'update'} = $self->to->update_records( $data_split->{'update' } );
  };
  if( scalar @{ $data_split->{'delete'} } and ! $params->{'no_delete'} ) {
    $result_split->{'delete'} = $self->to->delete_records( $data_split->{'delete'} );
  };
  $result_split->{'skip'} = scalar @{ $data_split->{'skip'} };

  $result_split->{'expected'} = { map { $_ => scalar @{ $data_split->{$_} } } keys %$data_split };

  return $result_split;
}

sub update_without_deleting_records {
  my ( $self, $data ) = @_;
  return $self->update_records( $data, { 'no_delete' => 1 } );
}

1;
