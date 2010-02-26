#!perl -T

use strict;
use warnings;
use Test::More tests => 16;

use Business::ID::NIK;

ok(!(validate_nik("") ? 1:0), "procedural style (1)");
ok((validate_nik("01 0000 010101 0001") ? 1:0), "procedural style (2)");

isa_ok(Business::ID::NIK->new(""), "Business::ID::NIK", "new works on invalid NIK");

ok(Business::ID::NIK->new("01 0000 010101 0001")->validate, "valid NIK (1)");
ok(Business::ID::NIK->new("01 0000 710101 0001")->validate, "valid NIK (2)");

ok(!Business::ID::NIK->new("00 0000 010101 0001")->validate, "invalid NIK: unknown province (1)");
ok(!Business::ID::NIK->new("40 0000 010101 0001")->validate, "invalid NIK: unknown province (2)");

ok(!Business::ID::NIK->new("01 0000 300201 0001")->validate, "invalid NIK: invalid date");

ok(!Business::ID::NIK->new("01 0000 300201 0000")->validate, "invalid NIK: zero serial");

is(Business::ID::NIK->new("01 0000 010101 0001")->area_code, "010000", "area_code");

isa_ok(Business::ID::NIK->new("01 0000 010101 0001")->date_of_birth, "DateTime", "date_of_birth");
isa_ok(Business::ID::NIK->new("01 0000 010101 0001")->dob, "DateTime", "date_of_birth (alias, dob)");

is(Business::ID::NIK->new("01 0000 010101 0001")->gender, "M", "gender (1)");
is(Business::ID::NIK->new("01 0000 410101 0001")->gender, "F", "gender (2)");

is(Business::ID::NIK->new("01 0000 010101 0001")->serial, "0001", "serial");

is(Business::ID::NIK->new("01.00.00.010101.0001")->normalize, "0100000101010001", "normalize");
