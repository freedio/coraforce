( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Basic Exception module for FORCE-linux 4.19.0-5-amd64 ******

package force/trouble
import /force/intel/64/core/ForthBase
import /force/core/Inout
import model/Severity
import model/StackTrace
import Exception

class: BasicException implements Exception
  requires Severity
  requires StackTrace



  === Fields ===

  Severity val Severity                               ( how severe the exception is )
  StackTrace val Stacktrace                           ( Snapshot of the caller stack at the time I was created )



  === Methods ===

public:
  : eprint ( -- )                                     ( print the exception to stderr )
    ecr  my Severity adj my class name e$. ;
  construct: new ( # -- )                             ( initialize instance with severity # )
    my Severity !  StackTrace new my Stacktrace ! ;

class;
