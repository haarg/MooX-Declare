use strictures 1;
use Test::More;

use MooX::Declare;

class Bar {
  use Types::Standard qw(:all);

  method foo () {
    print "$self YARR\n";
  }

  after foo {
    print "wark $self\n";
  }

  sub bar {}
}
Bar->new->foo();
ok 1;
done_testing;
