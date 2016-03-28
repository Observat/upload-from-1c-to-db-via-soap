#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use open qw/:std :utf8/;

use Getopt::Long;
use File::Find;
use FindBin;
use Test::Harness;

use lib "$FindBin::Bin/lib";


#====== VARS ======

my $help = qq{
Параметры:
  -t		запустить тесты ./t/\$t/*
  --all		запустить все тесты ( аналогично "-t ." )
  --help	справка
Пример:
  ./test.pl -t Esap-Model-Network
};

my $subcatalog_in_t;
my $flag_help;
my $flag_all;

Getopt::Long::GetOptions(
  'help|?'	=> \$flag_help,
  'all'		=> \$flag_all,
  't=s'		=> \$subcatalog_in_t,
) or die("Error in command line arguments\n");


#====== RUN ======

my @test_files = ();
my $dir = './t/';
if( defined $subcatalog_in_t ) {
  $dir = "./t/${subcatalog_in_t}/";
};

if( $flag_all or defined $subcatalog_in_t ) {
  File::Find::find(
    { no_chdir => 1,
      wanted => sub { if( /\.t$/) { push @test_files, $_ } }
    },
    $dir
  );

  Test::Harness::runtests( sort @test_files);
}

unless( scalar @test_files ) {
  print $help;
}
