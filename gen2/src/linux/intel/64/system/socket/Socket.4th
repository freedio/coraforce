( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Socket Module for FORCE-linux 4.19.0-5-amd64 ******

class: Socket extends IO
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

public:
  AddressFamily val AddressFamily
  Protocol val Protocol
  SocketType val Type
  SocketMode val Mode



  === Methods ===

protected:
  construct: copy ( Socket -- )  !Socket              ( initialize from the specified socket )
    dup AddressFamily@ my AddressFamily!  dup Protocol@ my Protocol!  dup Type@ my Type!  dup Mode@ my Mode!  Handle@ my Handle! ;
  construct: copyraw ( Socket -- )  !Socket           ( initialize from the specified socket )
    dup AddressFamily@ my AddressFamily!  dup Protocol@ my Protocol!  dup Type@ my Type!  dup Mode@ my Mode! ;
  : BooleanOption! ( ? lvl SocketOption -- x )        ( set boolean SocketOption on lvl to ?; may return x, mostly 0 )
    rot cell allot tuck ! dup >x 4 2swap >bits my Handle@ SYS-SETSOCKOPT, SystemResult1  x> free ;  fallible
  : IntOption! ( n lvl SocketOption -- x )            ( set int SocketOption on lvl to n; may return x, mostly 0 )
    rot cell allot tuck ! dup >x 4 2swap >bits my Handle@ SYS-SETSOCKOPT, SystemResult1  x> free ;  fallible
  : StructOption! ( a # lvl SocketOption -- x )       ( set structure SocketOption on lvl to a#; may return x, mostly 0 )
    >bits my Handle@ SYS-SETSOCKOPT, SystemResult1 ;  fallible
  : BooleanOption@ ( lvl SocketOption -- ? )          ( get boolean SocketOption ? on lvl )
    >bits cell allot dup >x 4 2swap my Handle@ SYS-GETSOCKOPT, SystemResult0  x> dup i@ swap free ;  fallible
  : IntOption@ ( lvl SocketOption -- n )              ( get int SocketOption n on lvl )
    >bits cell allot dup >x 4 2swap my Handle@ SYS-GETSOCKOPT, SystemResult0  x> dup i@ swap free ;  fallible
  : StructOption@ ( a # lvl SocketOption -- x )       ( get structure SocketOption on lvl in preallocated buffer a# )
    2over 2swap my Handle@ SYS-GETSOCKOPT, SystemResult1 ;

public:
static:
  : new ( AddressFamily Protocol SocketType SocketMode -- )  FreeSocket new SEP ( somebody else's problem, handle exception somewhere else ) ;

class;
