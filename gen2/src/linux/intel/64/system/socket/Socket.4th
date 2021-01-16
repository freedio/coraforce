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
  construct: copyraw ( Socket -- )  !Socket              ( initialize from the specified socket )
    dup AddressFamily@ my AddressFamily!  dup Protocol@ my Protocol!  dup Type@ my Type!  dup Mode@ my Mode! ;

public:
  : bind ( SocketAddress -- BoundSocket )             ( bind the socket to the specified address; returns a bound socket )
    trip Size my Handle@ SYS-BIND, SystemResult0  OK if  my BoundSocket new  else  drop  then ;  fallible unheritable


  : connect ( SocketAddress -- )                      ( connect the socket )
    dup SocketAddress size  my Handle@ SYS-CONNECT SystemResult0  OK if  SocketStatus Connected Status +!  then ;  fallible
  : accept ( SocketAddress -- Socket )                ( accept a connection )
    dup SocketAddress size  my Handle@ SYS-ACCEPT SystemResult1  OK if  my newPeer  then ;  fallible
  : send ( a # SocketIOMode -- #' )                   ( like write, but controlled by an I/O-mode )
    0 0 rot my Handle@ SYS-SENDTO, SystemResult1 ;  fallible
  : sendTo ( a # SocketIOMode Socket -- #' )          ( send data block a# to specified socket; reports #' bytes actually sent )
    dup SocketAddress size rot my Handle@ SYS-SENDTO, SystemResult1 ;  fallible
  : receive ( # SocketIOMode -- ★a #' )               ( like read, but controlled by an I/O-mode )
    >x dup allocate dup rot 0 dup x> my Handle@ SYS-RECVFROM, SystemResult1  KO if  free  then ;  fallible
  : receiveFrom ( # SocketIOMode Socket -- ★a #' )    ( receive # bytes from the specified socket; reports #' bytes written  )
    rot dup allocate dup rot ( iom soc a a # ) 4 roll dup SocketAddressD3f3nd3r8s
     size ;  fallible

static:
  : new ( AddressFamily Protocol SocketType SocketMode -- )  FreeSocket new SEP ( somebody else's problem, handle exception somewhere else ) ;

class;
