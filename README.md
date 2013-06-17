MooX::Declare - Declarative syntax for Moo
------------------------------------------
This is an in-progress analog to MooseX::Declare for Moo.  It is
pure perl, using [Filter::Keyword][1] instead of Devel::Declare to
intercept the parsing.  Types are provided by Type::Tiny.

Filter::Keyword
---------------
[Filter::Keyword][1] is partly implemented as a source filter, but
does not suffer from the problems other source filters encounter.
*insert explanation how here.*

Type::Tiny
----------
Type::Tiny is used for the types in method signatures.  It currently
allows the types from Types::Standard to be used, as well as any
others registered in the class' registry.  Hopefully this will be
made more friendly in the future.

[1]: http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/Filter-Keyword.git;a=shortlog;h=refs/heads/single-filter
