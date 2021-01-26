( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Free Socket Module for FORCE-linux 4.19.0-5-amd64 ******

class: FreeSocket extends Socket
  package linux/intel/64/system/socket
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===



  === Methods ===

public:
  : bind ( SocketAddress -- BoundSocket )             ( bind the socket to the specified address; returns a bound socket )
    trip Size my Handle@ SYS-BIND, SystemResult0  OK if  my newBoundSocket  else  drop  then ;  fallible
  construct: new ( AddressFamily Protocol SocketType SocketMode -- )
    my SocketMode!  my SocketType!  my Protocol!  dup my AddressFamily!
    ( my AddressFamily@ ) >bits  my SocketMode@ >openbits my SocketType@ >bits +  my Protocol@ >bits  SYS-SOCKET, SystemResult1
    OK if  ^ new  then ;  cascaded  fallible

class;
