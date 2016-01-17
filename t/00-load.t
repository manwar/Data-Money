#!perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 2;

BEGIN {
    use_ok('Data::Money')            || print "Bail out!\n";
    use_ok('Data::Money::Exception') || print "Bail out!\n";
}

diag("Testing Data::Money $Data::Money::VERSION, Perl $], $^X");
