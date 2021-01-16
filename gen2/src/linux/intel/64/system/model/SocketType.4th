( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux SocketType model for FORCE-linux 4.19.0-5-amd64 ******

enum: SocketType
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol unknown                      ( unknown socket type )
  symbol Stream                       ( Sequenced, reliable, connection-based byte streams: SOCK_STREAM )
  symbol Datagram                     ( Connectionless, unreliable datagrams of fixed maximum length: SOCK_DGRAM )
  symbol Raw                          ( Raw protocol interface: SOCK_RAW )
  symbol RDM                          ( Reliably-delivered message: SOCK_RDM )
  symbol SeqPacket                    ( Sequenced, reliable, connection-based datagrams of fixed maximum length: SOCK_SEQPACKET )
  symbol DCCP                         ( Datagram Congestion Control Protocol: SOCK_DCCP )
  symbol Packet                       ( Linux specific way of getting packets at the dev level.  For writing rarp and other similar
                                        things on the user level: SOCK_PACKET )



  === Methods ===



enum;
