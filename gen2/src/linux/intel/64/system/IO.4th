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
  : readFrom ( a # -- #' t | LinuxError f )           ( read # bytes from fd into buffer a, report actually read in #' )
    my Handle SYS-READ, SystemResult1 ;
  : writeTo ( a # -- #' t | LinuxError f )            ( write # bytes from buffer a to fd, report actually written in #' )
    my Handle SYS-WRITE, SystemResult1 ;
  : close ( -- t | LinuxError f )  my Handle SYS-CLOSE, SystemError0 ;   ( close the handle )
  : control ( Any cmd -- x|0 t | LinuxError f )       ( perform I/O-control operation cmd with in/out argument Any¹ )
    my Handler SYS-IOCTL, SystemError1 ;              ( ¹ may return result result x, but Any is modified to return result )
  : readVectorFrom ( @v #v -- # t | LinuxError f )    ( read vector @v#v, report actual bytes read in # )
    my Handle SYS-READV, SystemResult1 ;
  : writeVectorTo ( @v #v -- # t | LinuxError f )     ( write vector @v#v, report actual bytes written in # )
    my Handle SYS-READV, SystemResult1 ;

construct: ( u4 -- )  my Handle! ;

class;
