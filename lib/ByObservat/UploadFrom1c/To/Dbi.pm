package ByObservat::UploadFrom1c::To::Dbi;
use Mojo::Base '-base';
use utf8;

has 'dbh';

has 'table_name';
has 'table_key';
has 'table_fields';

has 'main_object';

sub report { return $_[0]->main_object->report; }

sub get_count {
  my ( $self ) = @_;

  my $result = $self->dbh->selectrow_arrayref( "SELECT COUNT(*) FROM ".$self->table_name );
  unless( defined $result ) {
    $self->report->add_log( "Не удалось получить количество записей в таблице ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
    return undef;
  }

  return $result->[0];
}

sub get_record {
  my ( $self, $pk ) = @_;

  return undef unless defined $pk;

  my $query = "SELECT ".( join ', ', @{$self->table_fields} )." FROM ".$self->table_name." WHERE ".$self->table_key."=?;";

  my $result = $self->dbh->selectrow_hashref( $query, undef, $pk );
  unless( defined $result ) {
    if( defined $self->dbh->errstr ) {
      $self->report->add_log( "Не удалось получить запись $pk в таблице ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
    }
    else {
      $self->report->add( "Отсутствует запись $pk в таблице ".$self->table_name, 'info' );
    };
    return undef;
  }

  return $result;
}

sub get_all_pk {
  my ( $self ) = @_;

  my $query = "SELECT ".$self->table_key." FROM ".$self->table_name.";";

  my $result = $self->dbh->selectall_arrayref( $query );
  unless( defined $result ) {
    $self->report->add_log( "Не удалось получить первичные ключи в таблице ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
    return undef;
  }

  return [ map { $_->[0] } @$result ];
}

sub get_all_records {
  my ( $self ) = @_;

  my $query = "SELECT ".( join ', ', @{$self->table_fields} )." FROM ".$self->table_name.";";

  my $result = $self->dbh->selectall_arrayref( $query, { Slice => {} } );
  unless( defined $result ) {
    $self->report->add_log( "Не удалось получить записи в таблице ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
  }

  return $result;
}

sub insert_records {
  my ( $self, $data ) = @_;

  my $block_query_one = '(' . ( join ', ', ('?')x( scalar @{$self->table_fields} ) ) . ')' ;
  my $block_query_into = $self->table_name.'( ' . ( join ', ', @{$self->table_fields} ) . ' )';
  my $query = "INSERT INTO $block_query_into VALUES $block_query_one;";

  my $count = 0;
  foreach my $data_row ( @$data ) {
    my $result = $self->dbh->do( $query, undef, @$data_row{ @{$self->table_fields} } );
    if( $result ) {
      $self->report->add_log( "Вставлена запись [".( join ', ', map { $_//'' } @$data_row{ @{$self->table_fields} } )."] в таблицу ".$self->table_name.".", 'debug' );
      $count += $result;
    }
    else {
      $self->report->add_log( "НЕ вставлена запись [".( join ', ', map { $_//'' } @$data_row{ @{$self->table_fields} } )."] в таблицу ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
    }
  };

  return $count;
}

sub update_records {
  my ( $self, $data ) = @_;

  my @fields_for_update = grep { $_ ne $self->table_key } @{$self->table_fields};

  my $block_query_set = join ', ', map { "$_=?" } @fields_for_update;
  my $query = "UPDATE ".$self->table_name." SET $block_query_set WHERE ".$self->table_key."=?;";

  my $count = 0;
  foreach my $data_row ( @$data ) {
    my $old_row = $self->get_record( $data_row->{$self->table_key} );
    my $result = $self->dbh->do( $query, undef, @$data_row{ @fields_for_update }, $data_row->{$self->table_key} );
    if( $result ) {
      my $message = "Обновлена запись ".$data_row->{$self->table_key}." в таблице ".$self->table_name.". ";
      $message .= "Новое значение [".( join ', ', map { $_//'' } @$data_row{ @{$self->table_fields} } )."]";
      $message .= ", старое значение [".( join ', ', map { $_//'' } @$old_row{ @{$self->table_fields} } )."]";
      $self->report->add_log( $message, 'debug' );
      $count += $result;
    }
    else {
      $self->report->add_log( "НЕ обновлена запись ".$data_row->{$self->table_key}." в таблице ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
    }
  };

  return $count;
}

sub delete_records {
  my ( $self, $pk_arr ) = @_;

  my $query = "DELETE FROM ".$self->table_name." WHERE ".$self->table_key."=?;";

  my $count = 0;
  foreach my $pk ( @$pk_arr ) {
    my $row = $self->get_record( $pk );
    my $result = $self->dbh->do( $query, undef, $pk );
    if( $result ) {
      $self->report->add_log( "Удалена запись [".( join ', ', map { $_//'' } @$row{ @{$self->table_fields} } )."] из таблицы ".$self->table_name.".", 'debug' );
      $count += $result;
    }
    else {
      $self->report->add_log( "НЕ удалена запись [".( join ', ', map { $_//'' } @$row{ @{$self->table_fields} } )."] из таблицы ".$self->table_name.": ".$self->dbh->errstr, 'warning' );
    }
  }

  return $count;
}

1;
