( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Socket Option model for FORCE-linux 4.19.0-5-amd64 ******

enum: SocketOption
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol invalid                      ( invalid option )
  symbol Debug?                       ( socket debugging enabled? requires user root or cap_net_admin: SO_DEBUG )
  symbol ReuseAddress?                ( reuse of local addresses? boolean: SO_REUSEADDR )
  symbol Type#                        ( Socket type; integer; r/o: SO_TYPE )
  symbol Error#                       ( Current socket error; reset when read; r/o: SO_ERROR )
  symbol DontRoute?                   ( send directly, not via gateway? boolean: SO_DONTROUTE )
  symbol Broadcast?                   ( broadcasting datagram packets? boolean: SO_BROADCAST )
  symbol SendBufferSize#              ( Size of the send buffer; max 1024=2048; integer: SO_SNDBUF )
  symbol ReceiveBufferSize#           ( Size of the receive buffer; max 128=256; integer: SO_RCVBUF )
  symbol KeepAlive?                   ( are keep-alive messages sent? boolean: SO_KEEPALIVE )
  symbol OutOfBandInline              ( out-of-band data in receive data stream allowed? boolean: SO_OOBINLINE )
  symbol NoCheck                      ( ?: SO_NO_CHECK )
  symbol Priority#                    ( priority of packets sent [protocol-specific]; integer: SO_PRIORITY )
  symbol Linger&                      ( if and how long the connection lingers when closed; structure: SO_LINGER )
  symbol BSDcompat?                   ( is socket BSD compatible? deprecated; boolean: SO_BSDCOMPAT )
  symbol ReusePort?                   ( are multiple sockets allowed to use the same address? boolean: SO_REUSEPORT )
  symbol PassCredentials?             ( are SCM_CREDENTIALS ctrl-msgs enabled? boolean: SO_PASSCRED )
  symbol PeerCredentials&             ( Credentials of the socket peer; r/o; structure: SO_PEERCRED )
  symbol ReceiveMinimum#              ( Minimum #bytes in recv buffer until rdy; integer: SO_RCVLOWAT )
  symbol SendMinimum#                 ( Minimum #bytes in send buffer until rdy; r/o = 1; integer: SO_SNDLOWAT )
  symbol ReceiveTimeoutOld&           ( Receive timeout; structure: SO_RCVTIMEO_OLD )
  symbol SendTimeoutOld&              ( Send timeout; structure: SO_SNDTIMEO_OLD )
  symbol Authentication               ( ?: SO_SECURITY_AUTHENTICATION )
  symbol TransportEncryption          ( ?: SO_SECURITY_ENCRYPTION_TRANSPORT )
  symbol NetworkEncryption            ( ?: SO_SECURITY_ENCRYPTION_NETWORK )
  symbol BindToDevice$                ( [un]bind socket from/to device name; devname⁰: SO_BINDTODEVICE )
  symbol AttachFilter&                ( filter attached to the socket; structure; SO_ATTACH_FILTER )
  symbol DetachFilter  alias DetachBPF  ( remove filter attached to the socket; w/o: SO_DETACH_FILTER, SO_DETACH_BPF )
  symbol PeerName                     ( ?: SO_PEERNAME )
  symbol TimestampOld?                ( are SCM_TIMESTAMP ctrl-msgs enabled? boolean: SO_TIMESTAMP_OLD )
  symbol Listening?                   ( is socket listening for connections? r/o; boolean: SO_ACCEPTCONN )
  symbol PeerSecurity                 ( ?: SO_PEERSEC )
  3 :skip
  symbol PassSecurity?                ( reception of SCM_SECURITY ctrl-msgs enabled? boolean: SO_PASSSEC )
  symbol TimestampNSOld?              ( reception of SCM_TIMESTAMPNS ctrl-msgs enabled? boolean: SO_TIMESTAMPNS_OLD )
  symbol MarkPackets?                 ( is mark on packets set? requires cap_net_admin; boolean: SO_MARK )
  symbol TimestampingOld?             ( ?: SO_TIMESTAMPING_OLD )
  symbol Protocol#                    ( the socket protocol such as IPPROTO_ICMP; integer: SO_PROTOCOL )
  symbol Domain#                      ( the socket domain/address family such as AF_INET6; integer: SO_DOMAIN )
  symbol DroppedPackets?              ( 32-bit ancillary cmsg attached about dropped packets? boolean: SO_RXQ_OVFL )
  symbol WifiStatus                   ( ?: SO_WIFI_STATUS )
  symbol PeekOffset#                  ( the peek offset; integer; SO_PEEK_OFF )
  symbol NoFCS                        ( ?: SO_NOFCS )
  symbol LockFilter?                  ( socket locked for further filtering? boolean; SO_LOCK_FILTER )
  symbol SelectErrorQueue?            ( deprecated; boolean; SO_SELECT_ERR_QUEUE )
  symbol BusyPoll                     ( ?: SO_BUSY_POLL )
  symbol MaximumPacingRate#           ( ?: SO_MAX_PACING_RATE )
  symbol BPFextensions?               ( ?: SO_BPF_EXTENSIONS )
  symbol IncomingCPU#                 ( CPU affinity of the socket; integer: SO_INCOMING_CPU )
  symbol AttachBPF#                   ( extended filter attached to the socket; integer [filedescr]: SO_ATTACH_BPF )
  symbol AttachReusePortClassicBPF&   ( Classic filter for reuse-port sockets; structure: SO_ATTACH_REUSEPORT_CBPF )
  symbol AttachReusePortExtendedBPF&  ( Extended filter for reuse-port sockets; structure: SO_ATTACH_REUSEPORT_EBPF )
  symbol CnxAdvice                    ( ?: SO_CNX_ADVICE )
  symbol TimestampingOptionStats      ( ?: SO_TIMESTAMPING_OPT_STATS )
  symbol MemoryInfo                   ( ?: SO_MEMINFO )
  symbol IncomingNAPI-ID              ( ?: SO_INCOMING_NAPI_ID )
  symbol Cookie                       ( ?: SO_COOKIE )
  symbol TimestampingPacketInfo       ( ?: SO_TIMESTAMPING_PKTINFO )
  symbol PeerGroups                   ( ?: SO_PEERGROUPS )
  symbol ZeroCopy                     ( ?: SO_ZEROCOPY )
  symbol TransferTime                 ( ?: SO_TXTIME )
  symbol BindToIFIndex                ( ?: SP_BINDTOIFINDEX )
  symbol TimestampNew?                ( are SCM_TIMESTAMP ctrl-msgs enabled? boolean: SO_TIMESTAMP_NEW )
  symbol TimestampNSNew?              ( reception of SCM_TIMESTAMPNS ctrl-msgs enabled? boolean: SO_TIMESTAMPNS_NEW )
  symbol TimestampingNew?             ( ?: SO_TIMESTAMPING_NEW )
  symbol ReceiveTimeoutNew&           ( Receive timeout; structure: SO_RCVTIMEO_NEW )
  symbol SendTimeoutNew&              ( Send timeout; structure: SO_SNDTIMEO_NEW )

  TimestampNew? =symbol Timestamp?
  TimestampNSNew? =symbol TimestampNS?
  TimestampingNew? =symbol Timestamping?
  ReceiveTimeoutNew& =symbol ReceiveTimeout&
  SendTimeoutNew& =symbol SendTimeout&

  === Methods ===



enum;
