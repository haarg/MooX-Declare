package MooX::Declare::HasParams;
use Types::Standard qw(Any Optional);
use Type::Params;
use Moo::Role;

sub param_filter {
  my ($self, $pattern) = @_;
  return {
    match => qr/(?:\(([^()]*)\)\s*)?\{/,
    process => sub {
      my ($name, $stripped, $matches) = @_;

      my $param_string = '';
      my $params = $matches->[0];
      if (defined $params) {
        $param_string = $self->parse_signature($params);
      }
      $stripped =~ s/.*?\{/$param_string/;

      return (sprintf($pattern, $name) . $stripped, 1);
    },
  };
}

my $param_re = qr/([^,()]*?)\s*(:?)(\$[a-zA-Z_]\w*)/;

our @PARAM_CHECK;

sub parse_signature {
  my ($self, $params) = @_;
  my @params;
  my @types;
  while ($params =~ s/^\s*$param_re\s*(?:,|$)//) {
    my ($type, $optional, $param) = ($1, $2, $3);
    my $type_object = $type ? do {
      $type =~ s/\s+$//;
      my $t;
      eval qq{ package @{[ $self->target ]}; \$t = $type }
        or die $@;
      $t;
    } : Any;
    if ($optional) {
      $type_object = Optional[$type_object];
    }
    push @params, $param;
    push @types, $type_object;
  }
  if ($params ne '') {
    die "invalid parameter string '$params'";
  }
  if (@types) {
    my $assign = 'my (' . join(', ', @params) . ') = ';
#    if (!grep { !( $_->library && $_->name && $_->library eq 'Types::Standard' && $_->name eq 'Any' ) } @types) {
#      return $assign . '@_;';
#    }
#    else {
      push @PARAM_CHECK, Type::Params::compile(@types);
      return $assign . '$' . __PACKAGE__ . "::PARAM_CHECK[$#PARAM_CHECK]->(\@_);";
#    }
  }
  return;
}

1;
