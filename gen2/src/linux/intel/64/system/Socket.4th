( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Socket Module for FORCE-linux 4.19.0-5-amd64 ******

class: Socket extends IO
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===



  === Methods ===

public:


construct: new ( AddressFamily Protocol SocketType SocketMode -- )
  SocketMode >openbits swap SocketType + rot AddressFamily >bits rot Protocol > bits slide SYS-SOCKET, SystemResult1
  OK if  my Handle!  then ;

class;
