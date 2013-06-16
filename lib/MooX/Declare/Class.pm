package MooX::Declare::Class;
use strictures 1;

our $VERSION = '0.000001';
$VERSION = eval $VERSION;

use Role::Tiny::With;
with 'MooX::Declare::Filter', 'MooX::Declare::Methods';

1;
