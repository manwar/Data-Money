package Data::Money;

$Data::Money::VERSION   = '0.08';
$Data::Money::AUTHORITY = 'cpan:GPHAT';

use Moo;
use namespace::clean;

use Data::Dumper;
use Math::BigFloat;
use Data::Money::Exception;
use Locale::Currency::Format;
use Locale::Currency qw(code2currency);

use overload
    '+'     => \&add,
    '-'     => \&subtract,
    '*'     => \&multiply,
    '/'     => \&divide,
    '%'     => \&modulo,
    '+='    => \&add_in_place,
    '-='    => \&subtract_in_place,
    '*='    => \&multiply_in_place,
    '/='    => \&divide_in_place,
    '0+'    => sub { $_[0]->value->numify; },
    '""'    => sub { shift->stringify },
    'bool'  => sub { shift->as_int; },
    '<=>'   => \&three_way_compare,
    'cmp'   => \&three_way_compare,
    'abs'   => sub { shift->absolute },
    '='     => sub { shift->clone },
    'neg'   => \&negate,
    fallback => 1;


my $Amount = sub {
    my ($arg) = @_;

    return Math::BigFloat->new(0) unless defined $arg;

    if (ref($arg) eq 'Data::Money') {
        return Math::BigFloat->new($arg->value);
    }

    $arg =~ tr/-()0-9.//cd;
    if ($arg) {
        Math::BigFloat->new($arg);
    } else {
        Math::BigFloat->new(0);
    }
};

my $CurrencyCode = sub {
    my ($arg) = @_;

    die 'String is not a valid 3 letter currency code.'
        unless (defined $arg
                || ($arg =~ /^[A-Z]{3}$/mxs && defined code2currency($arg)));
};

my $Format = sub {
    my ($arg) = @_;

    my $format = {
        'FMT_COMMON'   => 1,
        'FMT_HTML'     => 1,
        'FMT_NAME'     => 1,
        'FMT_STANDARD' => 1,
        'FMT_SYMBOL'   => 1
    };

    die "Invalid Format [$arg]."
        unless (defined $arg || exists $format->{uc($arg)});
};

has code   => (is => 'rw', isa => $CurrencyCode, default => sub { 'USD'        });
has format => (is => 'rw', isa => $Format,       default => sub { 'FMT_COMMON' });
has value  => (is => 'rw', isa => $Amount,       default => sub { Math::BigFloat->new(0) }, coerce => $Amount);

sub BUILD {
    my ($self) = @_;

    my $exp = 0;
    my $dec = $self->value->copy->bmod(1);
    my $s = sprintf("Value [%s]", $self->value);
    $exp = $dec->exponent->babs if ($dec);
    my $prec = Math::BigInt->new($self->_decimal_precision);

    Data::Money::Exception->throw(error => 'Excessive precision for this currency type' . "[$exp][$prec][$s]" )
        if ($exp > $prec);
}

sub clone {
    my ($self, %param) = @_;

    $param{code}   = $self->code;
    $param{format} = $self->format;
    return Data::Money->new( \%param );
}

# Liberally jacked from Math::Currency
sub as_float {
    my ($self) = @_;

    return $self->value->copy->bfround(0 - $self->_decimal_precision)->bstr;
}

# Liberally jacked from Math::Currency
sub as_int {
    my ($self) = @_;

    (my $str = $self->as_float) =~ s/\.//omsx;
    $str =~ s/^(\-?)0+/$1/omsx;
    return $str eq '' ? '0' : $str;
}

sub absolute {
    my ($self) = @_;

    return $self->clone(value => abs $self->value);
}

sub negate {
    my ($self) = @_;

    return $self->absolute if ($self->value < 0);

    my $val = 0 - $self->value;
    return $self->clone(value => $val);
}

sub add {
    my $self = shift;
    my $num  = shift || 0;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }

        return $self->clone(value => $self->value->copy->badd($num->value));
    }

    return $self->clone(value => $self->value->copy->badd($self->clone(value => $num)->value))
}

sub add_in_place {
    my ($self, $num) = @_;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }

        $self->value($self->value->copy->badd($num->value));
    } else {
        $self->value($self->value->copy->badd($self->clone(value => $num)->value));
    }

    return $self;
}

sub name {
    my ($self) = @_;

    my $name = code2currency($self->code);
    ## Fix for older Locale::Currency w/mispelled Candian
    $name =~ s/Candian/Canadian/ms;

    return $name;
}

*as_string = \&stringify;

sub stringify {
    my $self   = shift;
    my $format = shift || $self->format;

    my $code = $self->code;

    ## funky eval to get string versions of constants back into the values
    eval '$format = Locale::Currency::Format::' .  $format;

    unless (_is_CurrencyCode($code)) {
        Data::Money::Exception->throw(error => 'Invalid currency code:  ' . ($code || 'undef'));
    }

    my $utf8 = _to_utf8(
        Locale::Currency::Format::currency_format($code, $self->absolute->as_float, $format)
    );

    if ($self->value < 0) {
        return "-$utf8";
    } else {
        return $utf8;
    }
}

sub subtract {
    my $self = shift;
    my $num = shift || 0;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }

        return $self->clone(value => $self->value->copy->bsub($num->value));
    }

    return $self->clone(value => $self->value->copy->bsub($self->clone(value => $num)->value))
}

sub subtract_in_place {
    my ($self, $num) = @_;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }
        $self->value($self->value->copy->bsub($num->value));
    } else {
        $self->value($self->value->copy->bsub($self->clone(value => $num)->value));
    }

    return $self;
}

sub multiply {
    my ($self, $num) = @_;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }

        return $self->clone(value => $self->value->copy->bmul($num->value));
    }

    return $self->clone(value => $self->value->copy->bmul($self->clone(value => $num)->value))
}

sub multiply_in_place {
    my ($self, $num) = @_;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }
        $self->value($self->value->copy->bmul($num->value));
    } else {
        $self->value($self->value->copy->bmul($self->clone(value => $num)->value));
    }

    return $self;
}

sub divide {
    my ($self, $num) = @_;

    my $val;
    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }

        $val = $self->value->copy->bdiv($num->value);
        my $prec = Locale::Currency::Format::decimal_precision($self->code);
        $val = sprintf('%.0'.$prec.'f', _round($val, $prec*-1));
        return $self->clone(value => $val);
    }

    $val = $self->value->copy->bdiv($self->clone(value => $num)->value);
    my $prec = Locale::Currency::Format::decimal_precision($self->code);
    $val = sprintf('%.0'.$prec.'f', _round($val, $prec*-1));

    return $self->clone(value => $val);
}

sub divide_in_place {
    my ($self, $num) = @_;

    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }
        my $val  = $self->value->copy->bdiv($num->value);
        my $prec = Locale::Currency::Format::decimal_precision($self->code);
        $val = sprintf('%.0'.$prec.'f', _round($val, $prec*-1));
        $self->value($val);
    } else {
        my $val = $self->value->copy->bdiv($self->clone(value => $num));
        my $prec = Locale::Currency::Format::decimal_precision($self->code);
        $val = sprintf('%.0'.$prec.'f', _round($val, $prec*-1));
        $self->value($val);
    }

    return $self;
}

sub modulo {
    my ($self, $num) = @_;

    my $val;
    if (ref($num) eq 'Data::Money') {
        if ($self->code ne $num->code) {
            Data::Money::Exception->throw(error => 'unable to perform arithmetic on different currency types');
        }

        $val = $self->value->copy->bmod($num->value);
        return $self->clone(value => $val);
    }

    $val = $self->value->copy->bmod($self->clone(value => $num)->value);
    return $self->clone(value => $val);
}

sub three_way_compare {
    my $self = shift;
    my $num  = shift || 0;

    my $y;
    if (ref($num) eq 'Data::Money') {
        $y = $num;
    } else {
        # we clone here to ensure that if we're comparing a number to
        # an object, that the currency codes match (and we don't just
        # get the default).
        $y = $self->clone(value => $num);
    }

    if ($self->code ne $y->code) {
        Data::Money::Exception->throw(error => 'unable to compare different currency types');
    }

    return $self->value->copy->bfround(0 - $self->_decimal_precision) <=> $y->value->copy->bfround(0 - $self->_decimal_precision);
}

#
#
# PRIVATE METHODS

sub _decimal_precision {
    my ($self, $code) = @_;

    $code ||= $self->code;
    my $format;

    ## funky eval to get string versions of constants back into the values
    eval '$format = Locale::Currency::Format::' .  $self->format;

    unless (_is_CurrencyCode($code)) {
        Data::Money::Exception->throw(error => 'Invalid currency code:  ' . ($code || 'undef'));
    }

    return Locale::Currency::Format::decimal_precision($code) || 0;
}

sub _to_utf8 {
    my $value = shift;

    if ($] >= 5.008) {
        require utf8;
        utf8::upgrade($value);
    };

    return $value;
};

sub _is_CurrencyCode {
    my ($code) = @_;

    return 0 unless defined $code;

    return defined code2currency($code, 'alpha');
}

# http://www.perlmonks.org/?node_id=24335
sub _round {
    my ($number, $places) = @_;

    my $sign = ($number < 0) ? '-' : '';
    my $abs  = abs($number);

    if ($places < 0) {
        $places *= -1;
        return $sign . substr($abs+("0." . "0" x $places . "5"), 0, $places+length(int($abs))+1);
    } else {
        my $p10 = 10**$places;
        return $sign . int($abs/$p10 + 0.5)*$p10;
    }
}

1;

__END__

=head1 NAME

Data::Money - Money/currency with formatting and overloading.

=head1 SYNOPSIS

    use Data::Money;

    my $price = Data::Money->new(value => 1.2. code => 'USD');
    print $price;            # $1.20
    print $price->code;      # USD
    print $price->format;    # FMT_COMMON
    print $price->as_string; # $1.20

    # Overloading, returns new instance
    my $m2 = $price + 1;
    my $m3 = $price - 1;
    my $m4 = $price * 1;
    my $m5 = $price / 1;
    my $m6 = $price % 1;

    # Objects work too
    my $m7 = $m2 + $m3;
    my $m8 = $m2 - $m3;
    my $m9 = $m2 * $m3;
    my $m10 = $m2 / $m3;

    # Modifies in place
    $price += 1;
    $price -= 1;
    $price *= 1;
    $price /= 1;

    # Compares against numbers
    if($m2 > 2)
    if($m2 < 3)
    if($m2 == 2.2)

    # And strings
    if($m2 gt '$2.00')
    if($m2 lt '$3.00')
    if($m2 eq '$2.20')

    # and objects
    if($m2 > $m3)
    if($m3 lt $m2)

    print $price->as_string('FMT_SYMBOL'); # $1.20

=head1 DESCRIPTION

The Data::Money module provides basic currency formatting and number handling
via L<Math::BigFloat|Math::BigFloat>:

    my $currency = Data::Money->new(value => 1.23);

Each Data::Money object will stringify to the original value except in string
context, where it stringifies to the format specified in C<format>.

=head1 MOTIVATION

Data::Money was created to make it easy to use different currencies (leveraging
existing work in C<Locale::Currency> and L<Moose|Moose>), to allow math operations
with proper rounding (via L<Math::BigFloat|Math::BigFloat>) and formatting via
L<Locale::Currency::Format|Locale::Currency::Format>.

=head1 OPERATOR OVERLOADING

Data::Money overrides some operators.  It is important to note which
operators change the object's value and which return new ones.  All
operators accept either a Data::Money argument or a normal number via
scalar, and will die if the currency types mismatch.

Data::Money overloads the following operators:

=over 4

=item +

Handled by the C<add> method.  Returns a new Data::Money object.

=item -

Handled by the C<subtract> method.  Returns a new Data::Money object.

=item S< >*

Handled by the C<multiply> method. Returns a new Data::Money object.

=item /

Handled by the C<divide> method. Returns a new Data::Money object.

=item +=

Handled by the C<add_in_place> method.  Modifies the left-hand object's value.
Works with either a Data::Money argument or a normal number.

=item -=

Handled by the C<subtract_in_place> method.  Modifies the left-hand object's value.
Works with either a Data::Money argument or a normal number.

=item *=

Handled by the C<multiply_in_place> method.  Modifies the left-hand object's value.
Works with either a Data::Money argument or a normal number.

=item /=

Handled by the C<divide_in_place> method.  Modifies the left-hand object's value.
Works with either a Data::Money argument or a normal number.

=item <=>

Performs a three way comparsion. Works with either a Data::Money argument or a
normal number.


=back

=head1 ATTRIBUTES

=head2 code

Gets/sets the three letter currency code for the current currency object.
Defaults to USD

=head2 format

Gets/sets the format to be used when C<as_string> is called. See
L<Locale::Currency::Format|Locale::Currency::Format> for the available
formatting options.  Defaults to C<FMT_COMMON>.

=head2 name

Returns the currency name for the current objects currency code. If no
currency code is set the method will die.

=head2 value

The amount of money/currency.  Defaults to 0.

=head1 METHODS

=head2 add($amount)

Adds the specified amount to this Data::Money object and returns a new
Data::Money object.  You can supply either a number of a Data::Money
object.  Note that this B<does not> modify the existing object.

=head2 add_in_place($amount)

Adds the specified amount to this Data::Money object, modifying its value.
You can supply either a number of a Data::Money object.  Note that this
B<does> modify the existing object.

=head2 as_int

Returns the object's value "in pennies" (in the US at least).  It
strips the value of formatting using C<as_float> and of any decimals.

=head2 as_float

Returns objects value without any formatting.

=head2 subtract($amount)

Subtracts the specified amount to this Data::Money object and returns a new
Data::Money object. You can supply either a number of a Data::Money
object. Note that this B<does not> modify the existing object.

=head2 subtract_in_place($amount)

Subtracts the specified amount to this Data::Money object, modifying its
value. You can supply either a number of a Data::Money object. Note that
this B<does> modify the existing object.

=head2 multiply($amount)

Multiplies the value of this Data::Money object and returns a new
Data::Money object. You can supply either a number of a Data::Money
object. Note that this B<does not> modify the existing object.

=head2 multiply_in_place($amount)

Multiplies the value of this Data::Money object, modifying its value. You
can supply either a number of a Data::Money object. Note that this B<does>
modify the existing object.

=head2 divide($amount)

Divides the value of this Data::Money object and returns a new
Data::Money object. You can supply either a number of a Data::Money
object. Note that this B<does not> modify the existing object.

=head2 divide_in_place($amount)

Divides the value of this Data::Money object, modifying its value. You can
supply either a number of a Data::Money object. Note that this B<does>
modify the existing object.

=head2 modulo

Performs the modulo operation on this Data::Money object, returning a new
Data::Money object with the value of the remainder.

=head2 three_way_compare

Compares a Data::Money object to another Data::Money object, or anything it is
capable of coercing - numbers, numerical strings, or Math::BigFloat objects. Both
numerical and string comparators work.

=head2 negate

Performs the negation operation, returning a new Data::Money object with the opposite
value (1 to -1, -2 to 2, etc).

=head2 absolute

Returns a new Data::Money object with the value set to the absolute value of the
original.

=head2 clone(%params)

Returns a clone (new instance) of this Data::Money object.  You may optionally
specify some of the attributes to overwrite.

  $curr->clone({ value => 100 }); # Clones all fields but changes value to 100

See L<MooseX::Clone|MooseX::Clone> for more information.

=head2 stringify

Sames as C<as_string>.

=head2 as_string

Returns the current objects value as a formatted currency string.

=head1 SEE ALSO

L<Locale::Currency|Locale::Currency>, L<Locale::Currency::Format|Locale::Currency::Format>,

=head1 ACKNOWLEDGEMENTS

This module was originally based on L<Data::Currency|Data::Currency> by Christopher H. Laco
but I opted to fork and create a whole new module because my work was wildly
different from the original. I decided it was better to make a new module than
to break back compat and surprise users. Many thanks to him for the great
module.

Inspiration and ideas were also drawn from L<Math::Currency|Math::Currency> and
L<Math::BigFloat|Math::BigFloat>.

Major contributions (more overloaded operators, disallowing operations on
mismatched currences, absolute value, negation and unit tests) from
Andrew Nelson C<< <anelson@cpan.org> >>.

Major contributions (more overloaded operators, disallowing operations on
mismatched currences, absolute value, negation and unit tests) from
Andrew Nelson.

=head1 AUTHOR

Cory G Watson, C<< <gphat at cpan.org> >>

Copyright 2010 Cory Watson

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
