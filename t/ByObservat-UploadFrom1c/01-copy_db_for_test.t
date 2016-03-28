#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use Test::More;

my $developDB = 'asu-soap';
my $testDB = 'soap_test';

my @dbi_connect = ( 'dbi:mysql:;host=esap.dev.gstu.by', 'test_user', 'test_user', { mysql_enable_utf8 => 1, RaiseError => 0 } );
sub _get_dbh { return DBI->connect( @dbi_connect ); }

my $dbh = _get_dbh();

$dbh->do("DROP DATABASE IF EXISTS `$testDB`");
$dbh->do("CREATE DATABASE `$testDB`");
$dbh->do("USE `$testDB`");

my @tables = ( qw/staff_basic/ );

my @query_prepare = grep { $_ !~ /^\s$/ } <DATA>;

plan tests => scalar( @tables ) + scalar( @query_prepare );

foreach my $table ( @tables ) {
    ok( $dbh->do("CREATE TABLE `$table` LIKE `$developDB`.`$table`"), "CREATE TABLE $table" );
}
foreach( @query_prepare ) {
    ok( $dbh->do( $_ ), ( $_ =~ /^(.+?)\(/ ) ? $1 : 'INSERT INTO ?' );
}

$dbh->disconnect;

__END__
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '12', 'Агафонов', 'Григорий', 'Алексеевич', 'Автотранспорт', 'Ведущий инженер по транспорту', '0123001H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '346', 'Капустин', 'Владимир', 'Иванович', 'Региональный центр тестирования и профессиональной ориентации учащейся молодежи', 'Начальник центра тестирования', '0123002H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '75', 'Потапова', 'Надежда', 'Петровна', 'Санаторий-профилакторий', 'Дежурный по профилакторию', '0123036H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '71', 'Козлова', 'Ольга', 'Валерьевна', 'Кафедра \"Белорусский и иностранные языки\"', 'Ассистент -преподаватель', '0173001H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '21', 'Васильева', 'Татьяна', 'Викторовна', 'Отдел воспитательной работы с молодежью', 'Педагог социальный', '0108201H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '22', 'Жуков', 'Сергей', 'Дмитриевич', 'Служба охраны', 'Сторож', '0172601H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '23', 'Панфилов', 'Юрий', 'Владимирович', 'Центр информационных технологий ', 'Инженер-программист 2 категории', '1023001H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '432', 'Воробьёв', 'Александр', 'Васильевич', 'Издательский центр', 'Редактор', '0123038H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '654', 'Пахомов', 'Юрий', 'Николаевич', 'Институт повышения квалификации и переподготовки кадров', 'Директор института повышения квалификации и переподготовки кадров', '0120341H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '666', 'Авдеев', 'Андрей', 'Викторович', 'Кафедра \"Разработка и эксплуатация нефтяных месторождений и транспорт нефти\"', 'Заведующий кафедрой', '0129101H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '777', 'Третьяков', 'Константин', 'Сергеевнмч', 'Кафедра \"Информационные технологии\"', 'Заведующий кафедрой', '0123701H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '888', 'Белозёров', 'Олег', 'Даниилович', 'Ректорат', 'Первый проректор', '0156701H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '999', 'Михайлов', 'Татьяна', 'Казимировна', 'Аспирантура', 'Заведующий аспирантурой', '4123001H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '9000', 'Кошелева', 'Людмила', 'Владимировна', 'Отдел международных связей', 'Переводчик 2 категории', '0223001H041PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '435', 'Сысоева', 'Людмила', 'Николаевна', 'Общежитие №1', 'Уборщик служебных помещений', '0124001H042PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '235', 'Гущин', 'Сергей', 'Иванович', 'Ректорат', 'ректор', '0123041H011PB8');
INSERT INTO `staff_basic`(`TAB_NOM`, `FAM`, `IMY`, `OTCH`, `PDR`, `DLG`, `LIN`) VALUES ( '32', 'Лихачёв', 'Виталий', 'Леонидович', 'Автотранспорт', 'Водитель автомобиля', '0123007H041PB8');
