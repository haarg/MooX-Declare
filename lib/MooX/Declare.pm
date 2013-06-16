package MooX::Declare;
use strictures 1;

our $VERSION = '0.000001';
$VERSION = eval $VERSION;

use Role::Tiny::With;
with 'MooX::Declare::Filter';

sub filters {
  (
    class => sub {
      my ($keyword, $parser) = @_;
      if (my ($stripped, $matches) = $parser->match_source('', '{')) {
        my $name = $parser->current_match->[0];
        $stripped =~ s/{/; { package ${name}; use Moo; use MooX::Declare::Class;/;
        return ($stripped, 1);
      }
      else {
        return ('', 1);
      }
    },
    role => sub {
      my ($keyword, $parser) = @_;
      if (my ($stripped, $matches) = $parser->match_source('', '{')) {
        my $name = $parser->current_match->[0];
        $stripped =~ s/{/; { package ${name}; use Moo::Role; use MooX::Declare::Role;/;
        return ($stripped, 1);
      }
      else {
        return ('', 1);
      }
    },
  )
}

1;
__END__

=head1 NAME

MooX::Declare - Declarative syntax for Moo

=head1 SYNOPSIS

  use MooX::Declare;

=head1 DESCRIPTION

Declarative syntax for Moo.

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head2 CONTRIBUTORS

None yet.

=head1 COPYRIGHT

Copyright (c) 2013 the L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself.

=cut
