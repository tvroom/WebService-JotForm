use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WebService::JotForm',
    AUTHOR           => q{Tim Vroom <vroom@blockstackers.com>},
    VERSION_FROM     => 'lib/WebService/JotForm.pm',
    ABSTRACT_FROM    => 'lib/WebService/JotForm.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
	'Carp' 			=> 0,
	'Moo'  			=> 0,
	'JSON::Any' 		=> 0,
	'LWP::UserAgent' 	=> 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WebService-JotForm-*' },
);
