package Data::Money::Exception;

$Data::Money::Exception::VERSION   = '0.08';
$Data::Money::Exception::AUTHORITY = 'cpan:GPHAT';

=head1 NAME

Data::Money::Exception - Exception handler for Data::Money.

=head1 VERSION

Version 0.08

=cut

use Moo;
use namespace::clean;
with 'Throwable';

use overload q{""} => 'as_string', fallback => 1;

has error => (is => 'ro', required => 1);

sub as_string {
    my ($self) = @_;

    return $self->error;
}

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

1; # End of Data::Money::Exception
