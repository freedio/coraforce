( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The ArithmeticException module for FORCE-linux 4.19.0-5-amd64 ******

package force/trouble
import force/intel/64/core/ForthBase
import Exception

class: BasicException implements Exception



  === Fields ===

  String val Message                                  ( human reable problem description )
  Severity val Severity                               ( how severe the exception is )
  Stacktrace val Stacktrace                           ( Snapshot of the caller stack at the time I was created )



  === Methods ===

public:
  : eprint ( -- )                                     ( print the exception to stderr )
    ecr  my Severity adj my class name e$.
  construct: new$ ( $ # -- )                          ( initialize instance with severity # and message $ )
    my Severity !  my Message !  Stacktrace new my Stacktrace ! ;

class;
