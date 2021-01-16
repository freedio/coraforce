( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Module for FORCE-linux 4.19.0-5-amd64 ******

class: IO
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U4 val Handle                                       ( Unix file descriptor, short fd )



  === Methods ===

public:
  : read ( # -- ★a #' )                               ( read # bytes from fd into new buffer ★a, report #' actually read )
    dup allocate dup rot my Handle@ SYS-READ, SystemResult1  KO if  free  then ;
  : readFrom ( a # -- #' )                            ( read # bytes from fd into buffer a, report actually read in #' )
    my Handle@ SYS-READ, SystemResult1 ;  fallible
  : writeTo ( a # -- #' )                             ( write # bytes from buffer a to fd, report actually written in #' )
    my Handle@ SYS-WRITE, SystemResult1 ;  fallible  alias write
  : close ( -- )  my Handle SYS-CLOSE, SystemResult0 ;  fallible    ( close the handle )
  : control ( Any cmd -- x|0 )                        ( perform I/O-control operation cmd with in/out argument Any¹ )
    my Handler@ SYS-IOCTL, SystemError1 ;  fallible     ( ¹ may return result result x, but often Any is modified to return result )
  : readVectorFrom ( @v #v -- # )                     ( read vector @v#v, report actual bytes read in # )
    my Handle@ SYS-READV, SystemResult1 ;  fallible
  : writeVectorTo ( @v #v -- # )                      ( write vector @v#v, report actual bytes written in # )
    my Handle@ SYS-READV, SystemResult1 ;  fallible
  : duplicate ( -- IO )                               ( duplicate the IO )
    my Handle@ SYS-DUP, SystemResult1  OK if  newIO  then ;
  : dupInto ( IO -- )                                 ( duplicate the IO into the specified IO )
    my Handle@ swap Handle@ SYS-DUP2,  SystemResult0 ;
  construct: new ( u4 -- )  my Handle! ;

class;
