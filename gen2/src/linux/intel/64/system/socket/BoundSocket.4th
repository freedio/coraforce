( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Bound Socket Module for FORCE-linux 4.19.0-5-amd64 ******

class: BoundSocket extends Socket
  package linux/intel/64/system/socket
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

public:
  SocketAddress val LocalAddress



  === Methods ===

protected:
  construct: copy ( BoundSocket -- )  dup LocalAddress@ my LocalAddress!  ^ copy ;  cascaded

public:
  : connect ( SocketAddress -- )                      ( connect the socket )
    trip SocketAddress Size  my Handle@ SYS-CONNECT, SystemResult0
    OK if  my ConnectedSocket fromBoundSocket  else  drop  then ;  fallible
  : listen ( u -- ListeningSocket )                   ( return passive socket listening for incoming connections )
    my Handle@ swap SYS-LISTEN, SystemResult0  OK if  my ListeningSocket new  then ;  fallible

  construct: new ( SocketAddress Socket -- )  ^ copy  my LocalAddress! ;  cascaded
      TODO: "^" already indicates "cascaded": why do we have to mark it here ↑ ?

class;
