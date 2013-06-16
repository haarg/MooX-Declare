package MooX::Declare::Filter;
use strictures 1;

our $VERSION = '0.000001';
$VERSION = eval $VERSION;

use Filter::Keyword;
use B::Hooks::EndOfScope;
use Role::Tiny;
use namespace::clean;
use Moo;

has target => (is => 'ro');

sub import {
  my ($class) = @_;
  my $target = caller;
  my $self = $class->new(target => $target);
  my %filters = $self->filters;
  my @keywords = map {
    Filter::Keyword->new(
      target_package => $target,
      keyword_name => $_,
      parser => $filters{$_},
    );
  } keys %filters;
  $_->install for @keywords;
  on_scope_end {
    $_->remove for @keywords;
  };
}

sub filters { () }

1;
