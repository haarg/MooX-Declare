package MooX::Declare::Methods;
use strictures 1;

our $VERSION = '0.000001';
$VERSION = eval $VERSION;

use Role::Tiny;
use Types::Standard qw(Any Optional);
use Type::Params;
use B::Hooks::EndOfScope;
use Filter::Util::Call;

around filters => sub {
  my $orig = shift;
  my $self = shift;
  (
    $self->$orig,
    method => sub {
      my ($keyword, $parser) = @_;
      my $name = $parser->current_match->[0];
      my $pre = "; sub $name { ";
      if (my $code = $self->parse_params($keyword, $parser, $pre)) {
        return ($code, 1);
      }
      else {
        return ('', 1);
      }
    },
    ( map { my $modifier = $_;
      "${modifier}" => sub {
        my ($keyword, $parser) = @_;
        my $name = $parser->current_match->[0];
        my $pre = "; __$modifier $name => sub { BEGIN { @{[ __PACKAGE__ ]}::_inject_semi } ";
        if ($_ eq 'around') {
          $pre .= 'my $orig = shift;'
        }
        if (my $code = $self->parse_params($keyword, $parser, $pre)) {
          return ($code, 1);
        }
        else {
          return ('', 1);
        }
      },
    } qw(before after around override) ),
  )
};

my $param_re = qr/(\w+\s|)\s*(:?)(\$[a-zA-Z_]\w*)/;

our @PARAM_CHECK;

sub parse_params {
  my ($self, $keyword, $kwp, $pre) = @_;
  if (my ($stripped, $matches) = $kwp->match_source('',
      qr/(?:\(([^()]+)\)\s*)?\{/)) {

    $pre .= 'my $self = shift;';

    if (my $params = $matches->[0]) {
      my $param_string = $self->parse_signature($keyword->target_package, $params);
      if (defined $param_string) {
        $pre .= $param_string;
      }
    }
    $stripped =~ s/.*?\{/$pre/;
    return $stripped;
  }
  return;
}

sub parse_signature {
  my ($self, $target_package, $params) = @_;
  my @params;
  my @types;
  while ($params =~ s/^\s*$param_re\s*(?:,|$)//) {
    my ($type, $optional, $param) = ($1, $2, $3);
    my $type_object = $type ? do {
      $type =~ s/\s+$//;
      my $t;
      eval qq{ package $target_package; \$t = $type }
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

sub _inject_semi {
  on_scope_end {
    filter_add(sub {
      my($status) ;
      $status = filter_read();
      if ($status >= 0) {
        $_ = ';' . $_;
      }
      filter_del();
      $status ;
    });
  };
}

1;
