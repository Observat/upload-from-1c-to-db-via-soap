#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw/:std :utf8/;
use FindBin;
use Mojo::Template;

# TODO Убрать EsapCommon::* из зависимостей
# TODO Добавить код выгрузки из 1с

# Если всё сделано правильно, то "wget http://soap.dev.gstu.by:8090/StaffBasic" будет выдавать 411
# Если 502, то ошибка в cgi-скрипте. Отсутствуют файлы EsapCommon::*

#===== VARS =====

# TODO DNS: добавить $domain в /var/lib/bind/zone/dev.gstu.by, увеличить серийный номер и выполнить service bind reload
# TODO firewall: добавить $listen в /etc/net/ifaces/default/fw/iptables/filter/INPUT и restart?
# TODO fcgi-сервер: используется spawn-fcgi

my $class = 'StaffBasic';
my $class_base = 'GstuSoap::'.$class;
my $listen = 8090;   # в nginx можно 127.0.0.1:8090, но в wsdl только порт нужен
my $domain = "soap.dev.gstu.by";

my $file_cgi = "../cgi/${class}.pl";
my $file_wsdl = "../../public/wsdl/${class}.wsdl";
my $file_nginx = "${domain}.conf";

my $etc_nginx_path = '/etc/nginx/';
my $webroot = "/var/www/webapps/${domain}/";
my $webroot_public = $webroot.'public/';
my $from = $FindBin::Bin.'/../../';


#===== SUBS =====

sub _clear {
  return; # TODO

  `rm -Rf ${webroot}`;
  `rm -Rf "${etc_nginx_path}sites-available.d/${domain}.conf"`;
  `rm -Rf "${etc_nginx_path}sites-enabled.d/${domain}.conf"`;
}

sub test_prepare {
  warn 'TODO Проверить права/sudo?';
  exit; # TODO

  if ( -f "${etc_nginx_path}sites-available.d/${domain}.conf" ) {
    die "Already exists ${etc_nginx_path}sites-available.d/${domain}.conf";
  };

  if ( -d $webroot ) {
    die "Already exists $webroot";
  };

  return 1;
}

sub render_cgi {
  my $mt = Mojo::Template->new;
  $mt->{'class'} = $class;
  $mt->{'class_base'} = $class_base;

  open( FILE, '>', $file_cgi ) or die "Can't open ${file_cgi}: $!";
  binmode( FILE, ':utf8' );
  print FILE $mt->render_file('./cgi.ep');
  close FILE;

  `chmod +x $file_cgi`;
}

sub render_wsdl {
  my $mt = Mojo::Template->new;
  $mt->{'class'} = $class;
  $mt->{'class_base'} = $class_base;
  $mt->{'domain'} = $domain;
  $mt->{'listen'} = $listen;

  open( FILE, '>', $file_wsdl ) or die "Can't open ${file_wsdl}: $!";
  binmode( FILE, ':utf8' );
  print FILE $mt->render_file('./wsdl.ep');
  close FILE;
}

sub render_nginx {
  my $mt = Mojo::Template->new;
  $mt->{'class'} = $class;
  $mt->{'domain'} = $domain;
  $mt->{'listen'} = $listen;
  $mt->{'webroot'} = $webroot;
  $mt->{'webroot_public'} = $webroot_public;

  open( FILE, '>', $file_nginx ) or die "Can't open ${file_nginx}: $!";
  binmode( FILE, ':utf8' );
  print FILE $mt->render_file('./nginx.ep');
  close FILE;
}


#===== RUN =====

warn 'Rendering cgi...';
render_cgi();
warn 'Rendering wsdl...';
render_wsdl();
warn 'Rendering nginx...';
render_nginx();

_clear(); # TODO

warn 'Checking installed server...';
exit unless test_prepare();

warn 'Installing server:';

warn " Coping in ${etc_nginx_path}...";
`cp -t ${etc_nginx_path}sites-available.d ${file_nginx}`;
`cd ${etc_nginx_path}sites-enabled.d && ln -s ../sites-available.d/${domain}.conf`;
# TODO chown?

warn ' Mkdir in /var/log/nginx/...';
`mkdir -p /var/log/nginx/${domain}/`;

warn ' Coping in webroot...';
`mkdir -p ${webroot}`;
# TODO Не все файлы нужны в $webroot. Например, каталог t/, и script/_dev/
`cp -vR ${from} ${webroot}`;
# TODO chown?

warn ' Restart service...';
`service nginx reload`;
`service spawn-fcgi restart`;
