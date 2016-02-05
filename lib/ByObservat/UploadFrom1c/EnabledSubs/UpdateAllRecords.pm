package ByObservat::UploadFrom1c::EnabledSubs::UpdateAllRecords;
use parent 'Exporter';
use utf8;

our @EXPORT = qw( updateAllRecords );

sub updateAllRecords {
  my ( $self, @data ) = @_;
  my $params = undef;  # { 'message_on_email' => 1 }; # TODO
  $self = $self->_init( $params );
  my $result = $self->update_records( \@data );

  my @for_resume_message = ( qw/insert update delete skip/ );
  my %for_resume_message = ( 'insert' => 'добавлено', 'update' => 'обновлено', 'delete' => 'удалено', 'skip' => 'пропущено' );
  my $message = 'Выгрузка '.(ref $self).' выполнена: ';
  $message .= join ', ', map { $for_resume_message{$_}.' '.( $result->{$_} // 0 ); } @for_resume_message;
  $message .= ".\n\n".$self->report->result_as_string;

  if( $self->{message_on_email} ) { # TODO or $result->{'delete'} ?
    EsapCommon::Log->email( $message, 'notice', $self->uid, { subject => 'Выгрузка '.(ref $self).' выполнена', to => 'soap_mail_to' } );
  };

  $result->{'message'} = $message;
  return $self->from->updateAllRecords( $result );
}

1;
