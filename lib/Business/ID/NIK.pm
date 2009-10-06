package Business::ID::NIK;

use warnings;
use strict;
use DateTime;
require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(validate_nik);

=head1 NAME

Business::ID::NIK - Validate Indonesian citizenship registration number (NIK)

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Business::ID::NIK;
    
    # OO-style

    my $nik = Business::ID::NIK->new($str);
    die "Invalid NIK!" unless $nik->validate;

    print $nik->area_code, "\n";
    print $nik->date_of_birth, "\n"; # also, dob()
    print $nik->gender, "\n"; # M for male, or F for female
    print $nik->serial, "\n";

    # procedural style

    validate_nik($str) or die "Invalid NIK!";
    
=head1 DESCRIPTION

This module can be used to validate Indonesian citizenship
registration number, Nomor Induk Kependudukan (NIK), or more popularly
known as Nomor Kartu Tanda Penduduk (Nomor KTP), because NIK is
displayed on the KTP (citizen identity card).

NIK is composed of 16 digits as follow:

 pp.DDSS.ddmmyy.ssss

pp.DDSS is a 6-digit area code where the NIK was registered (it used
to be but nowadays not always [citation needed] composed as: pp
2-digit province code, DD 2-digit city/district [kota/kabupaten] code,
SS 2-digit subdistrict [kecamatan] code), ddmmyy is date of birth of
the citizen (dd will be added by 40 for female), ssss is 4-digit
serial starting from 1.

=cut

# legend: S = not enough samples, SS = very few samples, D = dubious
# (other province also have lots of samples)

my %provinces = (
    '01' => undef, # doesn't seem to be "Nanggroe Aceh Darussalam"
    '02' => "Sumatera Utara",
    '03' => "Sumatera Barat",
    '04' => "Riau",
    '05' => "Jambi", # S
    '06' => "Sumatera Selatan",
    '07' => "Bengkulu",
    '08' => "Lampung",
    '09' => "DKI Jakarta",
    '10' => "Jawa Barat",
    '11' => "Jawa Tengah", # D=NAD
    '12' => "Jawa Timur",
    '13' => "Sumatera Barat", # D=DIY
    '14' => "Riau",
    '15' => "Jambi",
    '16' => "Sumatera Selatan",
    # where are the other Kalimantans?
    '17' => "Kalimantan Timur",
    '18' => "Lampung",
    '19' => "Kepulauan Bangka Belitung",
    '20' => "Sulawesi Tenggara",
    '21' => "Kepulauan Riau", # D=Sulawesi Selatan
    '22' => "Bali",
    '23' => "Nusa Tenggara Barat",
    '24' => "Nusa Tenggara Timur",
    '25' => "Maluku",
    '26' => "Sulawesi Utara", # S
    '27' => undef, # SS
    '28' => undef, # SS
    '29' => undef, # SS, doesn't exist?
    '30' => "Banten",
    '31' => undef, # SS
    '32' => "DKI/Jawa Barat/Banten", # lots of number beginning with this, national?
    '33' => "Jawa Tengah",
    '34' => "DI Yogyakarta",
    '35' => "Jawa Timur",
    '36' => "Banten",
    '37' => undef, # SS
    '38' => undef, # SS
    );

=head1 METHODS

=head2 new $str

Create a new C<Business::ID::NIK> object.

=cut

sub new {
    my ($class, $str) = @_;
    bless {
	_str => $str,
	_err => undef, # errstr
	_res => undef, # validation result cache
	_dob => undef,
	_gender => undef,
    }, $class;
}

=head2 validate()

Return true if NIK is valid, or false if otherwise. In the case of NIK
being invalid, you can call the errstr() method to get a description
of the error.

=cut

sub validate {
    my ($self, $another) = @_;
    return validate_nik($another) if $another;
    return $self->{_res} if defined($self->{_res});

    $self->{_res} = 0;
    for ($self->{_str}) {
	s/\D+//g;
	if (length != 16) {
	    $self->{_err} = "not 16 digit";
	    return;
	}
	if (/^(..)/ and !exists($provinces{$1})) {
	    $self->{_err} = "unknown province code"; 
	    return;
	}
	my ($d, $m, $y) = /^\d{6}(..)(..)(..)/;
	if ($d > 40) {
	    $self->{_gender} = 'F';
	    $d -= 40;
	} else {
	    $self->{_gender} = 'M';
	}
	my $today = DateTime->today;
	$y += int($today->year / 100) * 100;
	$y -= 100 if $y > $today->year;
	eval { $self->{_dob} = DateTime->new(day=>$d, month=>$m, year=>$y) };
	if ($@) {
	    $self->{_err} = "invalid date of birth: $d-$m-$y";
	    return;
	}
	/(....)$/;
	if ($1 < 1) {
	    $self->{_err} = "serial starts from 1, not 0";
	    return;
	}
    }
    $self->{_res} = 1;
}

=head2 errstr()

Return validation error of NIK, or undef if no error is found. See
C<validate()>.

=cut

sub errstr {
    my ($self) = @_;
    $self->validate and return;
    $self->{_err};
}

=head2 normalize()

Return formatted NIK, or undef if NIK is invalid.

=cut

sub normalize {
    my ($self, $another) = @_;
    return Business::ID::NIK->new($another)->normalize if $another;
    $self->validate or return;
    $self->{_str};
}

=head2 pretty()

Alias for normalize().

=cut

sub pretty { normalize(@_) }

=head2 area_code()

Return 6-digit province code + city/district + subdistrict component of NIK.

=cut

sub area_code {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^(\d{6})/;
    $1;
}

=head2 date_of_birth()

Return a DateTime object containing the date of birth component of the
NIK, or undef if NIK is invalid.

=cut

sub date_of_birth {
    my ($self) = @_;
    $self->validate or return;
    $self->{_dob};
}

=head2 dob()

Alias for day_of_birth()

=cut

sub dob { date_of_birth(@_) }

=head2 gender()

Return gender ('M' for male and 'F' for female), or undef if NIK is
invalid.

=cut

sub gender {
    my ($self) = @_;
    $self->validate or return;
    $self->{_gender};
}

=head2 serial()

Return 4-digit serial component of NIK, or undef if NIK is invalid.

=cut

sub serial {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /(\d{4})$/;
    $1;
}

=head1 FUNCTIONS

=head2 validate_nik($string)

Return true if NIK is valid, or false if otherwise. If you want to
know the error details, you need to use the OO version (see the
C<errstr> method).

Exported by default.

=cut

sub validate_nik {
    my ($str) = @_;
    Business::ID::NIK->new($str)->validate();
}

=head1 AUTHOR

Steven Haryanto, C<< <stevenharyanto at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-business-id-nik at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Business-ID-NIK>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Business::ID::NIK


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-ID-NIK>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Business-ID-NIK>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Business-ID-NIK>

=item * Search CPAN

L<http://search.cpan.org/dist/Business-ID-NIK/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Steven Haryanto.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
