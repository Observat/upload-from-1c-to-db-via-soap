#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

my @modules = qw(
  ByObservat::UploadFrom1c::From::Soap
  ByObservat::UploadFrom1c::To::Dbi
  ByObservat::UploadFrom1c
  GstuSoap::StaffBasic
);

plan tests => scalar @modules;

foreach( @modules ) {
  use_ok( $_ );
}
