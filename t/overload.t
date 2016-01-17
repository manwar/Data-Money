use Test::More tests => 74;
use strict;

use Data::Money;

# Stringify
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 1.01);

    cmp_ok($curr1, 'eq', '$0.01', 'stringification');
    cmp_ok($curr2, 'eq', '$0.99', 'stringification');
    cmp_ok($curr3, 'eq', '$1.01', 'stringification');
}

# Numify
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 1.01);

    cmp_ok($curr1, '==', 0.01, 'numification');
    cmp_ok($curr2, '==', 0.99, 'numification');
    cmp_ok($curr3, '==', 1.01, 'numification');

    ok($curr1 < $curr2, '< with Data::Money');
    ok($curr1 < 1, '< with number');

    ok($curr3 > $curr1, '> with Data::Money');
    ok($curr3 > 1, '> with number');

    ok($curr3 >= Data::Money->new(value => 1.01), '>= with Data::Money');
    ok($curr3 >= Data::Money->new(value => .01), '>= with Data::Money (again)');
    ok($curr3 >= 1.01, '>= with number');
    ok($curr3 >= .01, '>= with number (again)');

    ok($curr1 <= Data::Money->new(value => 1.01), '<= with Data::Money');
    ok($curr1 <= Data::Money->new(value => .01), '<= with Data::Money (again)');
    ok($curr1 <= 1.01, '<= with number');
    ok($curr1 <= .01, '<= with number (again)');

    ok($curr1 == Data::Money->new(value => 0.01), '== with Data::Money');
    ok($curr1 == 0.01, '== with number');
}

# Addition
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 1.01);

    cmp_ok($curr2 + $curr1, 'eq', '$1.00', '+ with Data::Money');
    cmp_ok($curr2 + 0.01, 'eq', '$1.00', '+ with number');
    cmp_ok($curr2 + .99, 'eq', '$1.98', '+ with number (again)');
}

# Subtraction
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 1.01);

    cmp_ok($curr2 - $curr1, 'eq', '$0.98', '- with Data::Money');
    cmp_ok($curr3 - $curr2, 'eq', '$0.02', '- with Data::Money (again)');
    cmp_ok($curr3 - 0.02, 'eq', '$0.99', '- with number');
}

# Multiplication (* and *=)
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 0.02);
    my $curr4 = Data::Money->new(value => 1.01);
    my $curr5 = Data::Money->new(value => 2.00);

    cmp_ok($curr1 * 2, 'eq', '$0.02', '* with number');
    cmp_ok($curr2 * 2, 'eq', '$1.98', '* with number (over a dollar)');
    cmp_ok($curr1 * $curr5, 'eq', '$0.02', '* with Data::Money');
    cmp_ok($curr2 * $curr5, 'eq', '$1.98', '* with Data::Money (over a dollar)');
    cmp_ok($curr1 * 2, 'eq', '$0.02', '*= with number');
    cmp_ok($curr2 * 2, 'eq', '$1.98', '*= with number (over a dollar)');
    cmp_ok($curr3 *= $curr5, 'eq', '$0.04', '*= with Data::Money');
    cmp_ok($curr4 *= $curr5, 'eq', '$2.02', '*= with Data::Money (over a dollar)');
}

# Division (/ and /=)
{
    my $curr1 = Data::Money->new(value => 1.00);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 0.04);
    my $curr4 = Data::Money->new(value => 3.99);
    my $curr5 = Data::Money->new(value => 2.00);

    cmp_ok($curr1 / 2, 'eq', '$0.50', '/ with number');
    cmp_ok($curr2 / 2, 'eq', '$0.50', '/ with number rounding');
    cmp_ok($curr3 / $curr5, 'eq', '$0.02', '/ with Data::Money');
    cmp_ok($curr4 / $curr5, 'eq', '$2.00', '/ with Data::Money rounding');
    cmp_ok($curr1 /= 2, 'eq', '$0.50', '/= with number');
    cmp_ok($curr2 /= 2, 'eq', '$0.50', '/= with number rounding');
    cmp_ok($curr3 /= $curr5, 'eq', '$0.02', '/= with Data::Money');
    cmp_ok($curr4 /= $curr5, 'eq', '$2.00', '/= with Data::Money rounding');
}

# +=
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 1.01);

    $curr1 += .99;
    cmp_ok($curr1, 'eq', '$1.00', '+= with number');

    $curr2 += $curr3;
    cmp_ok($curr2, 'eq', '$2.00', '+= Data::Money');
}

# -=
{
    my $curr1 = Data::Money->new(value => 0.01);
    my $curr2 = Data::Money->new(value => 0.99);
    my $curr3 = Data::Money->new(value => 1.01);

    $curr2 -= 0.50;
    cmp_ok($curr2, 'eq', '$0.49', '-= with number');

    my $currx = Data::Money->new(value => '1.01');
    my $curry = Data::Money->new(value => '0.49');
    $currx -= $curry;
    cmp_ok($currx, 'eq', '$0.52', '-= width Data::Money');
}

# boolean
{
    my $curr1 = new Data::Money;
    my $curr2 = Data::Money->new(value => 1);
    my $curr3 = Data::Money->new(value => 0);
    my $curr4 = Data::Money->new(value => -1);
    my $curr5 = Data::Money->new(value => 1.00);
    my $curr6 = Data::Money->new(value => 0.00);
    my $curr7 = Data::Money->new(value => -1.00);
    ok(!$curr1, 'boolean false on new object');
    ok($curr2, 'boolean true on int > 0');
    ok(!$curr3, 'boolean false on int == 0');
    ok($curr4, 'boolean true on int < 0');
    ok($curr5, 'boolean true on float > 0');
    ok(!$curr6, 'boolean false on float == 0');
    ok($curr7, 'boolean true on float < 0');
}

# disparate currency tests
{
    my $curr1 = Data::Money->new(value => 0.99, code => 'USD');
    my $curr2 = Data::Money->new(value => 0.99, code => 'CAD');

    eval { my $add_test = $curr1 + $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on +');

    eval { $curr1 += $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on +=');

    eval { my $sub_test = $curr1 - $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on -');

    eval { $curr1 -= $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on -=');

    eval { my $multiply_test = $curr1 * $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on *');

    eval { $curr1 *= $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on *=');

    eval { my $division_test = $curr1 / $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on /');

    eval { $curr1 /= $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on /=');

    eval { my $modulo_test = $curr1 % $curr2; };
    ok($@->error =~ /^unable to perform arithmetic on different currency types/, 'Disparate codes die on +');

    eval { my $lt_test = 'unable to compare different currency types' if($curr1 < $curr2); };
    ok($@->error =~ /^unable to compare different currency types/, 'Disparate codes die on <');

    eval { my $lteq_test = 'unable to compare different currency types' if($curr1 <= $curr2); };
    ok($@->error =~ /^unable to compare different currency types/, 'Disparate codes die on <=');

    eval { my $gt_test = 'unable to compare different currency types' if($curr1 > $curr2); };
    ok($@->error =~ /^unable to compare different currency types/, 'Disparate codes die on >');

    eval { my $gteq_test = 'unable to compare different currency types' if($curr1 >= $curr2); };
    ok($@->error =~ /^unable to compare different currency types/, 'Disparate codes die on >=');

}

# negative values and unary minus
{
    my $curr1 = Data::Money->new(value => -1.00);
    my $curr2 = Data::Money->new(value => -2.00);
    my $curr3 = Data::Money->new(value => 1.00);
    my $curr4 = Data::Money->new(value => 2.00);

    ok($curr1 < 0, 'Negative values with number');
    ok($curr2 < $curr1, 'Negative values with Data::Money');
    ok(-$curr3 eq '-$1.00', 'Unary minus works with number');
    ok(-$curr1 eq '$1.00', 'Unary minus works in reverse with number');
    ok(-$curr4 == $curr2, 'Unary minus works with Data::Money');
    ok(-$curr2 == $curr4, 'Unary minus works in reverse with Data::Money');
}


# absolute value
{
    my $curr1 = Data::Money->new(value => -1.00);
    my $curr2 = Data::Money->new(value => 1.00);

    ok(abs($curr1) == 1.00, 'Absolute value with number');
    ok(abs($curr1) == $curr2, 'Absolute value with Data::Money');
}

done_testing;
