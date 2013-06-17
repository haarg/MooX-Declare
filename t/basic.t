use strictures 1;
use Test::More;
use Test::Fatal;

use MooX::Declare;

my $after_called;

class Bar {
  method foo (Int $foo) {}

  method bar (Int|ArrayRef[Int] $foo) {  }

  after bar {
    $after_called++;
  }
}

is exception { Bar->new->foo(1); }, undef, 'can call method';
ok exception { Bar->new->foo("asd"); }, 'type constraint is checked';

is exception { Bar->new->bar(1); }, undef, 'can call method with complex type';
is exception { Bar->new->bar([1]); }, undef, 'can call method with complex type';
ok exception { Bar->new->bar(["asd"]); }, 'type constraint is checked';

is $after_called, 2, 'after called';

done_testing;
