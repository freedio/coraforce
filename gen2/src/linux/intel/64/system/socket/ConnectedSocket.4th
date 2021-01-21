( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Connected Socket Module for FORCE-linux 4.19.0-5-amd64 ******

class: ConnectedSocket extends Socket
  package linux/intel/64/system/socket
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

public:
  SocketAddress val LocalAddress
  SocketAddress val RemoteAddress



  === Methods ===

private:
  : initSocketName ( fd -- )  my Protocol@ SocketName  my LocalAddress! ;
  : initPeerName ( fd -- )  my Protocol@ PeerName  my RemoteAddress! ;
public:
  : send ( a # SocketIOMode -- #' )                   ( like write, but controlled by an I/O-mode )
    0 dup rot SocketIOMode >bits my Handle@ SYS-SENDTO, SystemResult1 ;  fallible
  : sendTo ( a # SocketIOMode SocketAddress -- #' )   ( send data block a# to specified address; reports #' bytes actually sent )
    dup Size rot SocketIOMode >bits my Handle@ SYS-SENDTO, SystemResult1 ;  fallible
  : receive ( # SocketIOMode -- ★a #' )               ( like read, but controlled by an I/O-mode )
    >x dup allocate dup rot 0 dup x> SocketIOMode >bits my Handle@ SYS-RECVFROM, SystemResult1  KO if  free  then ;  fallible
  : receiveFrom ( # SocketIOMode SocketAddress -- ★a #' ) ( read # bytes from specified sockaddr; reports #' bytes received )
    rot dup allocate dup rot ( iom sa a a # ) 4 roll dup Size ( iom a a # sa #sa ) 6 roll SocketIOMode >bits
    my Handle@ SYS-RECVFROM, SystemResult1  KO if  free  then ;  fallible
  : shutdown ( -- )                                   ( completely shuts down the full duplex connection )
    2 my Handle@ SYS-SHUTDOWN, SystemResult0 ;  fallible
  : shutdownReceiver ( -- )                           ( shuts down the receiver of the full duplex connection )
    0 my Handle@ SYS-SHUTDOWN, SystemResult0 ;  fallible
  : shutdownTransmitter ( -- )                        ( shuts down the transmitter of the full duplex connection )
    1 my Handle@ SYS-SHUTDOWN, SystemResult0 ;  fallible
  construct: new ( SocketAddress BoundSocket -- )     ( initialize from a bound socket that connected to a remote peer )
    !BoundSocket ^ copy  my RemoteAddress! ;  cascaded
  construct: fromServerSocket ( fd ServerSocket -- )  ( initialize from a server socket that accepted a connection )
    !ServerSocket ^ copyraw dup my Handle!  dup initSocketName  initPeerName ;  fallible

class;
