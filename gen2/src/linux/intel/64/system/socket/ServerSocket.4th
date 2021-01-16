( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux ServerSocket Module for FORCE-linux 4.19.0-5-amd64 ******

class: ServerSocket extends BoundSocket
  package linux/intel/64/system/socket
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U2 val Backlog



  === Methods ===

public:
  : accept ( SocketAddress -- ConnectedSocket )       ( accept a connection; returns a connected socket )
    trip SocketAddress Size  my Handle@ SYS-ACCEPT, SystemResult0  OK if  my ConnectedSocket new  else  drop  then ;  fallible
construct: new ( BoundSocket u -- )  my Backlog!  ^ copy ;  cascaded

class;
