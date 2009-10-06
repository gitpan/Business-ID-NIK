#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'Business::ID::KTP' );
    use_ok( 'Business::ID::NIK' );
}

diag( "Testing Business::ID::NIK $Business::ID::NIK::VERSION, Perl $], $^X" );
