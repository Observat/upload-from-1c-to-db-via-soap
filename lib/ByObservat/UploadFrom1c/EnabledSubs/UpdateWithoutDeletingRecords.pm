package ByObservat::UploadFrom1c::EnabledSubs::UpdateWithoutDeletingRecords;
use parent 'Exporter';
use utf8;

our @EXPORT = qw( updateWithoutDeletingRecords );

sub updateWithoutDeletingRecords {
  my ( $self, @data ) = @_;
  my $params = undef;
  $self = $self->_init( $params );

  ByObservat::Proxy::Log->add( 'Выгрузка '.(ref $self).' запущена', 'info', $self->uid );

  my $result = $self->update_without_deleting_records( \@data );

  my @fields = ( qw/insert update delete skip/ );
  my %for_message_in =  ( 'insert' => ' добавить', 'update' => ' обновить', 'delete' => 'удалить', 'skip' => 'пропустить' );
  my %for_message_out = ( 'insert' => 'добавлено', 'update' => 'обновлено', 'delete' => 'удалено', 'skip' => ' пропущено' );

  my $sum_in = 0;
  my $sum_out = 0;
  foreach( @fields ) {
    next if $_ eq 'delete';
    $sum_in  += $result->{'expected'}->{$_};
    $sum_out += $result->{$_};
  };

  my $message = 'Выгрузка '.(ref $self).' выполнена ';
  $message .= ( $sum_in == $sum_out ) ? 'успешно' : 'с ошибками';
  # TODO В @data дубликаты есть
  $message .= ".\nРеально получено ". scalar @data;
  $message .= ".\nЗапланировано $sum_in: ". join ', ', map { $for_message_in{$_}.' '.( $result->{'expected'}->{$_} // 0 ); } @fields;
  $message .= ".\nСделано       $sum_out: ". join ', ', map { $for_message_out{$_}.' '.( $result->{$_} // 0 ); } @fields;

  ByObservat::Proxy::Log->add( $message, 'info', $self->uid );

  $message .= ".\n".$self->report->result_as_string;

  if( $self->{message_on_email} ) {
    ByObservat::Proxy::Log->email( $message, 'notice', $self->uid, { subject => 'Выгрузка '.(ref $self).' выполнена', to => 'soap_mail_to' } );
  };

  $result->{'message'} = $message;
  return $self->from->updateWithoutDeletingRecords( $result );
}

1;
