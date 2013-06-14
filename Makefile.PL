
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

my %WriteMakefileArgs = (
  NAME => 'MooX::Declare',
  VERSION_FROM => 'lib/MooX/Declare.pm',

  PREREQ_PM => {
  },
  TEST_REQUIRES => {
    'Test::More' => 0.94,
  },
  MIN_PERL_VERSION => '5.8.1',

  META_MERGE => {
    dynamic_config => 0,
    resources => {
      repository => 'git://github.com/haarg/MooX-Declare.git',
      homepage => 'http://github.com/haarg/MooX-Declare',
    },
  },
);

for my $pre (
  ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ? ()
    : [ delete $WriteMakefileArgs{TEST_REQUIRES}, $WriteMakefileArgs{BUILD_REQUIRES} ] ),
  ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ? ()
    : [ delete $WriteMakefileArgs{BUILD_REQUIRES}, $WriteMakefileArgs{PREREQ_PM} ] ),
) {
  my ($from, $to) = @$pre;
  for my $mod ( keys %$from ) {
    $to->{$mod} = $from->{$mod}
      if !exists $to->{$mod}
        or $from->{$mod} > $to->{$mod};
  }
}

$WriteMakefileArgs{META_MERGE}{requires}{perl}
  = delete $WriteMakefileArgs{MIN_PERL_VERSION}
  unless eval { ExtUtils::MakeMaker->VERSION(6.47_01) };
delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };
delete $WriteMakefileArgs{META_MERGE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.45_01) };
delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.30_01) };

WriteMakefile(%WriteMakefileArgs);

