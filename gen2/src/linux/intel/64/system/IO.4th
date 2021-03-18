( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux I/O Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/memory/Memory
import SystemMacro
import IOBase

class: IO extends IO
  requires ForthBase
  requires Memory
  requires IOBase



  === Fields ===

  U4 val Handle                                       ( Unix file descriptor, short fd )



  === Methods ===

public:
  : read ( # -- ★a #' )                               ( read # bytes from fd into new buffer ★a; reports #' actually read )
    dup allocate dup rot my Handle@ SYS-READ, SystemResult1  KO if  free  then ;
  construct: new ( u4 -- )  ^ new ;

static:
  0 IO new const stdin                                ( predefined Standard Input I/O )
  1 IO new const stdout                               ( predefined Standard Output I/O )
  2 IO new const stderr                               ( predefined Standard Error I/O )

class;
