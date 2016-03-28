#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw/:std :utf8/;
use FindBin;
use Mojo::Template;
use Getopt::Long;

# Настроить окружение перед запуском:
#   DNS: добавить $domain в /var/lib/bind/zone/dev.gstu.by, увеличить серийный номер и выполнить service bind reload
#   firewall: добавить $listen в /etc/net/ifaces/default/fw/iptables/filter/INPUT и restart?
#   fastcgi-сервер: для обработки soap, тут используется spawn-fcgi через TCP/IP
#   БД: если используется в ByObservat::Proxy::Db.
#   lib/ByObservat/Proxy/*: заменить на свои реализации модулей.

# Если всё сделано правильно, то "wget http://домен:порт/класс" будет выдавать 411
# Если 502, то ошибка в cgi-скрипте. Например, в lib/ByObservat/Proxy/* используются несуществующие модули


#===== VARS =====

my $class		= 'StaffBasic';
my $class_base		= 'GstuSoap::StaffBasic';
my $domain		= 'soap.dev.gstu.by';
my $listen		= 8090; 	# в nginx можно 127.0.0.1:8090, но в wsdl только порт нужен
my $fastcgi_pass	= '127.0.0.1:1027';
my $path_test		= '../../t/ByObservat-UploadFrom1c/_for_test/*';

my $help = qq{
Параметры-переменные:
  class 	класс, видимый в soap ( default: $class );
  base  	базовый класс, который на самом деле делает обработку ( default: $class_base )
  domain	домен ( default: $domain )
  listen	порт ( default: $listen )
  fastcgi	подключение к fastcgi ( default: $fastcgi_pass )
  path-test	местонахождение файлов для теста, заменяющие некоторые файлы в \$webroot ( default: $path_test )
Параметры-action:
  render	рендерит cgi, wsdl и nginx
  remove	удаляет \$webroot и конфигурацию в nginx
  install	копирует файлы в \$webroot и создаёт конфигурацию в nginx
  copy-test	заменяет некоторые файлы в \$webroot файлами из \$path-test
  restart	выполняет "service nginx reload" и "service spawn-fcgi restart"
  update-all	последовательно выполняет render, remove, install и restart
  update-test	последовательно выполняет render, remove, install, copy-test и restart
  help		показывает эту справку
Примеры:
  ./INSTALL_soap_dev.pl --render --class=$class --base=$class_base --domain=soap-test.dev.gstu.by --listen $listen --fastcgi=$fastcgi_pass
  sudo ./INSTALL_soap_dev.pl --update-all
  sudo ./INSTALL_soap_dev.pl --update-test --path-test ../../t/ByObservat-UploadFrom1c/_for_test/ --class=Test --domain=soap-test.dev.gstu.by
};

my $flag_help;
my $flag_render;
my $flag_remove;
my $flag_install;
my $flag_copy_test;
my $flag_restart;
my $flag_update_all;
my $flag_update_test;

Getopt::Long::GetOptions( 'help|?'	=> \$flag_help,
            'render'	=> \$flag_render,
            'remove'	=> \$flag_remove,
            'install'	=> \$flag_install,
            'copy-test'	=> \$flag_copy_test,
            'restart'	=> \$flag_restart,
            'update-all'  => \$flag_update_all,
            'update-test' => \$flag_update_test,
            'class=s'	=> \$class,
            'base=s'	=> \$class_base,
            'domain=s'	=> \$domain,
            'listen=s'	=> \$listen,
            'fastcgi=s'	=> \$fastcgi_pass,
            'path-test=s' => \$path_test,
          )
  or die("Error in command line arguments\n");

if( $flag_update_test ) {
  $flag_update_all = $flag_update_test;
  $flag_copy_test  = $flag_update_test;
};
my $any_flag = $flag_help || $flag_render || $flag_remove || $flag_install || $flag_copy_test || $flag_restart || $flag_update_all || $flag_update_test;

my $file_cgi = "../cgi/${class}.pl";
my $file_wsdl = "../../public/wsdl/${class}.wsdl";
my $file_nginx = "${domain}.conf";

my $etc_nginx_path = '/etc/nginx/';
my $webroot = "/var/www/webapps/${domain}/";
my $webroot_public = "${webroot}public/";

my $from = $FindBin::Bin.'/../../';


#===== SUBS =====

sub test_prepare {
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
  $mt->{'fastcgi_pass'} = $fastcgi_pass;

  open( FILE, '>', $file_nginx ) or die "Can't open ${file_nginx}: $!";
  binmode( FILE, ':utf8' );
  print FILE $mt->render_file('./nginx.ep');
  close FILE;
}


#===== RUN =====

if( $flag_help or !$any_flag ) {
  print $help;
  exit;
}

if( $flag_render or $flag_update_all ) {
  print "Rendering file:\n";
  print " cgi\n";
  render_cgi();
  print " wsdl\n";
  render_wsdl();
  print " nginx\n";
  render_nginx();
};

if( $flag_remove or $flag_update_all ) {
  print "Removing:\n";
  print " rm -Rf ${webroot}\n";
  `rm -Rf ${webroot}`;
  print " rm -Rf ${etc_nginx_path}sites-available.d/${domain}.conf\n";
  `rm -Rf ${etc_nginx_path}sites-available.d/${domain}.conf`;
  print " rm -Rf ${etc_nginx_path}sites-enabled.d/${domain}.conf\n";
  `rm -Rf ${etc_nginx_path}sites-enabled.d/${domain}.conf`;
}

if( $flag_install or $flag_update_all ) {
  print "Installing server:\n";

  print " Checking installed server\n";
  last unless test_prepare();

  print " Mkdir in /var/log/nginx/\n";
  `mkdir -p /var/log/nginx/${domain}/`;

  print " Coping in ${etc_nginx_path}\n";
  `cp -t ${etc_nginx_path}sites-available.d ${file_nginx}`;
  `cd ${etc_nginx_path}sites-enabled.d && ln -s ../sites-available.d/${domain}.conf`;
  # chown?

  print " Coping in webroot\n";
  `mkdir -p ${webroot}`;
  `mkdir -p ${webroot}/lib`;
  `mkdir -p ${webroot}/script/cgi/`;
  `mkdir -p ${webroot}/public/wsdl/`;
  # TODO Не все файлы нужны в $webroot. Например, каталог t/, и script/_dev/
  `cp -vR ${from}/lib/* ${webroot}/lib/`;
  `cp -vR ${from}/public/wsdl/* ${webroot}/public/wsdl/`;
  `cp -v  ${from}/script/cgi/${file_cgi} ${webroot}/script/cgi/`;
  # chown?
}

if( $flag_copy_test ) {
  print "Copy for test:\n";
  print " cp -vR ${path_test} ${webroot}\n";
         `cp -vR ${path_test} ${webroot}`;
  print " cp -vR ${from}t ${webroot}t/\n";
         `cp -vR ${from}t ${webroot}t/`;
  print " cp -vR ${from}test_soap.sh ${webroot}\n";
         `cp -vR ${from}test_soap.sh ${webroot}`;
  # chown?
}

if( $flag_restart or $flag_update_all ) {
  print "Restart service:\n";
  print " service nginx reload\n";
  `service nginx reload`;
  print " service spawn-fcgi restart\n";
  `service spawn-fcgi restart`;
}
