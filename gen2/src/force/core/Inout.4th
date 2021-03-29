( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Input/Output module for FORCE-linux 4.19.0-5-amd64 ******

package /force/core
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/IOBase
import /force/intel/64/core/StringFormat

vocabulary: Inout
  requires IOBase
  requires StringFormat

private:
  10 =variable CR                                     ( single newline character )
  variable CHAR                                       ( character to emit )

private:
  : u>$ ( n -- ★$ )  "%D"| ;
  : n>$ ( n -- ★$ )  "%d"| ;
  : printx ( x IO 'x>$ )  swap >r execute dup count r> write and: drop free then ;  fallible
  : printn ( n IO -- )  ' n>$ printx ;
  : printu ( u IO -- )  ' u>$ printx ;

public:
  : cr ( -- )  CR 1 stdout write drop ;               ( emit a newline to standard output )
  : ecr ( -- )  CR 1 stderr write drop ;              ( emit a newline to standard error )
  : $. ( $ -- )  count stdout write drop ;            ( print $ to standard output )
  : $e. ( $ -- )  count stderr write drop ;           ( print $ to standard error )
  : emit ( c -- )  CHAR tuck c! 1 stdout write drop ; ( emit character c to standard output )
  : eemit ( c -- )  CHAR tuck c! 1 stderr write drop ; ( emit character c to standard error )
  : . ( n -- )  stdout printn ;  alias n.             ( print n to standard output )
  : e. ( n -- )  stderr printn ;  alias ne.           ( print n to standard error )
  : u. ( u -- )  stdout printu ;                      ( print u to standard output )
  : ue. ( u -- )  stderr printu ;                     ( print u to standard error )

vocabulary;
