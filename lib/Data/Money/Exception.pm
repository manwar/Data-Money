package Data::Money::Exception;

use Moo;
use namespace::clean;
with 'Throwable';

use overload q{""} => 'as_string', fallback => 1;

has error => (is => 'ro', required => 1);

sub as_string {
    my ($self) = @_;

    return $self->error;
}

1;
