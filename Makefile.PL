#!/usr/bin/perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Data::Money',
    AUTHOR             => q{Corey Watson <gphat@cpan.org>},
    VERSION_FROM       => 'lib/Data/Money.pm',
    ABSTRACT_FROM      => 'lib/Data/Money.pm',
    LICENSE            => 'artistic_2',
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More'      => '1.001014',
        'Test::utf8'      => 0,
        'Test::Exception' => 0,
    },
    PREREQ_PM => {
        'Moo'                      => '2.000000',
        'namespace::clean'         => '0.24',
        'Throwable'                => 0,
        'Check::ISA'               => 0,
        'Locale::Currency'         => '2.07',
        'Locale::Currency::Format' => '1.22',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Data-Money-*' },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/manwar/Data-Money.git',
                web  => 'https://github.com/manwar/Data-Money',
            },
        }})
     : ()
    ),
);
