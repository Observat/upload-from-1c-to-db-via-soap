package ByObservat::UploadFrom1c::EnabledSubs::UpdateWithoutDeletingRecords;
use parent 'Exporter';
use utf8;

our @EXPORT = qw( updateWithoutDeletingRecords );

sub updateWithoutDeletingRecords {
  # TODO Не помню про тестирование $message_ne
  my ( $self, @data ) = @_;
  my $params = undef;
  $self = $self->_init( $params );

  my $result = $self->update_without_deleting_records( \@data );

  my @fields = ( qw/insert update skip/ );

  my $message_ne = undef;
  my $sum = 0;
  foreach( @fields ) {
    $sum += $result->{$_};
  };
  if( scalar( @data ) != $sum ) {
    $message_ne = ', но количество обработанных не совпадает( получено '.scalar( @data ).", а обработано $sum )";
  }

  my %for_resume_message = ( 'insert' => 'добавлено', 'update' => 'обновлено', 'skip' => 'пропущено' );
  my $message = 'Выгрузка '.(ref $self).' выполнена'.($message_ne//'').': ';
  $message .= join ', ', map { $for_resume_message{$_}.' '.( $result->{$_} // 0 ); } @fields;
  $message .= ".\n\n".$self->report->result_as_string;

  if( defined $message_ne or $self->{message_on_email} ) {
    EsapCommon::Log->email( $message, 'notice', $self->uid, { subject => 'Выгрузка '.(ref $self).' выполнена', to => 'soap_mail_to' } );
  };

  $result->{'message'} = $message;
  return $self->from->updateWithoutDeletingRecords( $result );
}

1;
