#!/usr/bin/env perl
# Generated Tue Feb  9 13:43:36 2016
use SOAP::Lite;
use SOAP::Transport::HTTP;

SOAP::Transport::HTTP::CGI
    ->dispatch_to( "StaffBasic" )
    ->options({compress_threshold => 10000})
    ->handle;

package StaffBasic;
use strict;
use warnings;
use utf8;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use base 'GstuSoap::StaffBasic';

1;
