package Data::Money::Exception::InvalidCurrencyCode;

$Data::Money::Exception::InvalidCurrencyCode::VERSION   = '0.08';
$Data::Money::Exception::InvalidCurrencyCode::AUTHORITY = 'cpan:GPHAT';

=head1 NAME

Data::Money::Exception::InvalidCurrencyCode - Exception handle for 'invalid currency code'.

=head1 VERSION

Version 0.08

=cut

use 5.006;
use Data::Dumper;

use Moo;
use namespace::clean;

has error => (is => 'ro', default => sub { 'String is not a valid 3 letter currency code.' });

with 'Data::Money::Exception';

=head1 DESCRIPTION

B<FOR INTERNAL USE ONLY>

=head1 AUTHOR

Cory G Watson, C<< <gphat at cpan.org> >>

Currently maintained by Mohammad S Anwar (MANWAR) C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/manwar/Data-Money>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Cory Watson

This program is free software; you can redistribute it and/or modify it under the
terms of either: the GNU General Public License as published by the Free Software
Foundation; or the Artistic License.

See L<here|http://dev.perl.org/licenses> for more information.

=cut

1; # End of Data::Money::Exception::InvalidCurrencyCode
