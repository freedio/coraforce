( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Socket I/O Mode model for FORCE-linux 4.19.0-5-amd64 ******

U4 enumset: SocketIOMode
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol OutOfBand                      ( send out-of-band data if socket / protocol supports it: MSG_OOB )
  symbol Peek                           ( ?: MSG_PEEK )
  symbol NoRouting  alias TryHard       ( don't use gateway: route directly: MSG_DONTROUTE; try hard on DecNet: MSG_TRYHARD )
  symbol CTruncate                      ( ?: MSG_CTRUNC )
  symbol Probe                          ( don't send, just probe path, e.g. for MTU: MSG_PROBE )
  symbol Truncate                       ( ?: MSG_TRUNC )
  symbol NonBlocking                    ( send this message in non-blocking mode, if socket / protocol support it: MSG_DONTWAIT )
  symbol EndOfRecord                    ( terminate record, if socket / protocol [e.g. SeqPacket] support it: MSG_EOR )
  symbol AwaitFullRequest               ( Wait for a full request: MSG_WAITALL )
  symbol FIN  alias EOT                 ( Terminate the connection [i.e. no more data will follow]: MSG_FIN, MSG_EOF )
  symbol SYN                            ( ?: MSG_SYN )
  symbol Confirm                        ( Confirm receipt of message on the link layer: MSG_CONFIRM )
  symbol RST                            ( ?: MSG_RST )
  symbol FromErrorQueue                 ( Fetch message from error queue: MSG_ERRQUEUE )
  symbol NoSignal                       ( Don't generate SIGPIPE if the peer broke the connection: MSG_NOSIGNAL )
  symbol More                           ( More data will follow: MSG_MORE )
  symbol WaitFor1                       ( wait until at least one packet is available: MSG_WAITFORONE )
  1 :skip
  symbol Batch                          ( More messages will follow: MSG_BATCH )



  === Methods ===



enumset;
