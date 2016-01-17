#!perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 6;

BEGIN {
    use_ok('Data::Money')                                   || print "Bail out!\n";
    use_ok('Data::Money::Exception')                        || print "Bail out!\n";
    use_ok('Data::Money::Exception::ExcessivePrecision')    || print "Bail out!\n";
    use_ok('Data::Money::Exception::InvalidCurrencyCode')   || print "Bail out!\n";
    use_ok('Data::Money::Exception::InvalidCurrencyFormat') || print "Bail out!\n";
    use_ok('Data::Money::Exception::MismatchCurrencyType')  || print "Bail out!\n";
}

diag("Testing Data::Money $Data::Money::VERSION, Perl $], $^X");
