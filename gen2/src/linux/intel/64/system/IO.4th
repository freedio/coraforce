( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux I/O Module for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64/system
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/memory/Memory
import SystemMacro

class: IO
  requires ForthBase
  requires Memory



  === Fields ===

  U4 val Handle                                       ( Unix file descriptor, short fd )



  === Methods ===

public:
  : read ( # -- ★a #' )                               ( read # bytes from fd into new buffer ★a; reports #' actually read )
    dup allocate dup rot my Handle@ SYS-READ, SystemResult1  KO if  free  then ;
  : readFrom ( a # -- #' )                            ( read # bytes from fd into buffer a; reports actually read in #' )
    my Handle@ SYS-READ, SystemResult1 ;  fallible
  : writeTo ( a # -- #' )                             ( write # bytes from buffer a to fd; reports actually written in #' )
    my Handle@ SYS-WRITE, SystemResult1 ;  fallible  alias write
  : print$ ( $ --  )  my Handle@ SYS-WRITE, SystemResult1 ;  fallible    ( print counted string $ to fd )
  : close ( -- )  my Handle SYS-CLOSE, SystemResult0 ;  fallible    ( close the handle )
  : sendTo ( IO # -- #' )                             ( send # bytes from this IO to the specified IO; reports actually xferred #' )
    my Handle@ rot Handle@ 0 rot SYS-SENDFILE, SystemResult1 ;  fallible
  : receiveFrom ( IO # -- #' )                        ( send # bytes from the specified IO to this IO; reports actually xferred #' )
    swap Handle@ my Handle@ 0 rot SYS-SENDFILE, SystemResult1 ;  fallible
  : control ( Any cmd -- x|0 )                        ( perform I/O-control operation cmd with in/out argument Any¹ )
    my Handler@ SYS-IOCTL, SystemError1 ;  fallible     ( ¹ may return result result x, but often Any is modified to return result )
  : readVectorFrom ( @v #v -- # )                     ( read vector @v#v, report actual bytes read in # )
    my Handle@ SYS-READV, SystemResult1 ;  fallible
  : writeVectorTo ( @v #v -- # )                      ( write vector @v#v, report actual bytes written in # )
    my Handle@ SYS-READV, SystemResult1 ;  fallible
  : duplicate ( -- IO )                               ( duplicate the IO )
    my Handle@ SYS-DUPFD, SystemResult1  OK if  newIO  then ;  fallible
  : dupInto ( IO -- )                                 ( duplicate the IO into the specified IO )
    my Handle@ swap Handle@ SYS-DUP2,  SystemResult0 ;
  construct: new ( u4 -- )  my Handle! ;

static:
  0 IO new const stdin                                ( predefined Standard Input I/O )
  1 IO new const stdout                               ( predefined Standard Output I/O )
  2 IO new const stderr                               ( predefined Standard Error I/O )

class;
