( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Module for FORCE-linux 4.19.0-5-amd64 ******

class: IO  extends Object
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U4 val Handle                                       ( Unix file descriptor, short fd )



  === Methods ===

  : readFrom ( a # -- #' t | err f )                  ( read # bytes from fd into buffer a, report actually read in #' )
    my Handle SYS-READ, RESULT1, ;
  : writeTo ( a # -- #' t | err f )                   ( write # bytes from buffer a to fd, report actually written in #' )
    my Handle SYS-WRITE, RESULT1, ;
  : close ( -- t | err f )  my Handle SYS-CLOSE, RESULT0, ;   ( close the handle )


class;
