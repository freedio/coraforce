( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux I/O Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system
import /force/intel/64/core/ForthBase
import SystemMacro
import /force/intel/64/core/Errors

class: IOBase
  requires ForthBase
  requires Errors



  === Interface ===

  U4 val Handle                                       ( Unix file descriptor, short fd )

  def readFrom ( a # -- #' )                          ( read # bytes from fd into buffer a; reports actually read in #' )
  def writeTo ( a # -- #' )                           ( write # bytes from buffer a to fd; reports actually written in #' )
  def close ( -- )                                    ( close the handle )
  def sendTo ( IO # -- #' )                           ( send # bytes from this IO to the specified IO; reports actually xferred #' )
  def receiveFrom ( IO # -- #' )                      ( send # bytes from the specified IO to this IO; reports actually xferred #' )
  def control ( Any cmd -- x|0 )                      ( perform I/O-control operation cmd with in/out argument Any¹ )
  def readVectorFrom ( @v #v -- # )                   ( read vector @v#v, report actual bytes read in # )
  def writeVectorTo ( @v #v -- # )                    ( write vector @v#v, report actual bytes written in # )
  def duplicate ( -- IO )                             ( duplicate the IO )
  def dupInto ( IO -- )                               ( duplicate the IO into the specified IO )
  constructor new ( h -- )                            ( initialize IOBase with handle h )



  === Implementation ===

  : readFrom ( a # -- #' )                            ( read # bytes from fd into buffer a; reports actually read in #' )
    my Handle@ SYS-READ, Result1 ;  fallible
  : writeTo ( a # -- #' )                             ( write # bytes from buffer a to fd; reports actually written in #' )
    my Handle@ SYS-WRITE, Result1 ;  fallible  alias write
  : close ( -- )  my Handle SYS-CLOSE, Result0 ;  fallible    ( close the handle )
  : sendTo ( IO # -- #' )                             ( send # bytes from this IO to the specified IO; reports actually xferred #' )
    my Handle@ rot Handle@ 0 rot SYS-SENDFILE, Result1 ;  fallible
  : receiveFrom ( IO # -- #' )                        ( send # bytes from the specified IO to this IO; reports actually xferred #' )
    swap Handle@ my Handle@ 0 rot SYS-SENDFILE, Result1 ;  fallible
  : control ( Any cmd -- x|0 )                        ( perform I/O-control operation cmd with in/out argument Any¹ )
    my Handle@ SYS-IOCTL, Result1 ;  fallible           ( ¹ may return result result x, but often Any is modified to return result )
  : readVectorFrom ( @v #v -- # )                     ( read vector @v#v, report actual bytes read in # )
    my Handle@ SYS-READV, Result1 ;  fallible
  : writeVectorTo ( @v #v -- # )                      ( write vector @v#v, report actual bytes written in # )
    my Handle@ SYS-READV, Result1 ;  fallible
  : duplicate ( -- IO )                               ( duplicate the IO )
    my Handle@ SYS-DUPFD, Result1  OK if  IOBase new  then ;  fallible
  : dupInto ( IO -- )                                 ( duplicate the IO into the specified IO )
    my Handle@ swap Handle@ SYS-DUP2,  Result0 ;
  : new ( u4 -- )  my Handle d! ;

class;
