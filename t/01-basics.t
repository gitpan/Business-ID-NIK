#!perl

use 5.010;
use strict;
use warnings;

use Business::ID::NIK qw(parse_nik);
use Data::Clean::JSON;
use Test::More 0.98;

test_parse(nik=>"32 7300 010101 0001", status=>200);
test_parse(nik=>"32 7300 710101 0001", status=>200);

test_parse(nik=>"32 7300 320180 0001", status=>400, name=>"invalid date");

DONE_TESTING:
done_testing;

sub test_parse {
    state $cleanser = Data::Clean::JSON->new;

    my %args = @_;
    subtest +($args{name} //= "nik $args{nik}"), sub {
        my $res = $cleanser->clean_in_place(parse_nik(nik => $args{nik}));
        if ($args{status}) {
            is($res->[0], $args{status}) or diag explain $res;
        }
        if ($args{posttest}) {
            $args{posttest}->($res);
        }
    };
}
