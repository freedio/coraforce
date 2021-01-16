( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Protocol model for FORCE-linux 4.19.0-5-amd64 ******

enum: Protocol
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol unspecified          ( unspecified communication domain: AF_UNSPEC )
  symbol Unix  alias local    ( Unix address family: AF_UNIX, AF_LOCAL )
  symbol Internet4            ( Internet IP V4: AF_INET )
  symbol AX25                 ( Amateur Radio AX.25: AF_AX25 )
  symbol IPX                  ( Novell IPX: AF_IPX )
  symbol AppleTalk            ( AppleTalk DDP: AF_APPLETALK )
  symbol NetRom               ( Amateur Radio NET/ROM: AF_NETROM )
  symbol Bridge               ( Multiprotocol bridge: AF_BRIDGE )
  symbol ATMPVC               ( ATM PVCs: AF_ATMPVC )
  symbol X25                  ( ITU-T X.25 / ISO-8208 protocol: AF_AX25 )
  symbol Internet6            ( IP version 6: AF_INET6 )
  symbol Rose                 ( Amateur Radio X.25 PLP: AF_ROSE )
  symbol DECnet               ( Reserved for DECnet project: AF_DECnet )
  symbol NETBEUI              ( Reserved for 802.2LLC project: AF_NETBEUI )
  symbol Security             ( Security callback pseudo address family: AF_SECURITY )
  symbol Key                  ( PF_KEY key management API: AF_KEY )
  symbol Netlink  alias Route ( Netlink: AF_NETLINK )
  symbol Packet               ( Packet family: AF_PACKET )
  symbol Ash                  ( Ash: AF_ASH )
  symbol Econet               ( Acorn Econet: AF_ECONET )
  symbol ATMSVC               ( ATM SVCs: AF_ATMSVC )
  symbol RDS                  ( RDS sockets: AF_RDS )
  symbol SNA                  ( Linux SNA Project [nutters!]: AF_SNA )
  symbol IRDA                 ( IRDA sockets: AF_IRDA )
  symbol PPPoX                ( PPPoX sockets: AF_PPPOX )
  symbol Wanpipe              ( Wanpipe API Sockets: AF_WANPIPE )
  symbol LLC                  ( Linux LLC: AF_LLC )
  symbol InfiniBand           ( Native InfiniBand address: AF_IB )
  symbol MPLS                 ( MPLS: AF_MPLS )
  symbol CAN                  ( Controller Area Network: AF_CAN )
  symbol TIPC                 ( TIPC sockets: AF_TIPC )
  symbol Bluetooth            ( Bluetooth sockets: AF_BLUETOOTH )
  symbol IUCV                 ( IUCV sockets: AF_IUCV )
  symbol RxRCP                ( RxRPC sockets: AF_RXRCP )
  symbol ISDN                 ( mISDN sockets: AF_ISDN )
  symbol Phonet               ( Phonet sockets: AF_PHONET )
  symbol IEEE802154           ( IEEE802154 sockets: AF_IEEE802154 )
  symbol CAIF                 ( CAIF sockets: AF_CAIF )
  symbol Algorithm            ( Algorithm sockets: AF_ALG )
  symbol NFC                  ( NFC sockets: AF_NFC )
  symbol VSocket              ( vSockets: AF_VSOCK )
  symbol KCM                  ( Kernel Connection Multiplexer: AF_KCM )
  symbol QIPCRouter           ( Qualcomm IPC Router: AF_QIPCRTR )
  symbol SMC                  ( smc sockets: reserve number for PF_SMC protocol family that reuses AF_INET address family: AF_SMC )
  symbol XDP                  ( XDP [express data path] interface: AF_XDP )



  === Methods ===

public:
  : Address@ ( [Protocol] -- SocketAddress )  case   ( LocalAddress of socket with Handle fd )
      unspecified of:  "Can't get socket address of unspecified protocol!"| ERROR handle  of;
      Unix of:  UnixSocketAddress alloc  of;
      Internet4 of:  Internet4Address alloc  of;
      AX25 of:  AX25Address alloc  of;
      IPX of:  IPXSocketAddress alloc  of;
      AppleTalk of:  AppleTalkSocketAddress alloc  of;
      NetRom of:  NetRomSocketAddress alloc  of;
      Bridge of:  BridgeSocketAddress alloc  of;
      ATMPVC of:  ATMPVCSocketAddress alloc  of;
      X25 of:  X25SocketAddress alloc  of;
      Internet6 of:  Internet6SocketAddress alloc  of;
      Rose of:  RoseSocketAddress alloc  of;
      DECnet of:  DECnetSocketAddress alloc  of;
      NETBEUI of:  NETBEUISocketAddress alloc  of;
      Security of:  SecuritySocketAddress alloc  of;
      Key of:  KeySocketAddress alloc  of;
      Netlink of:  NetlinkSocketAddress alloc  of;
      Packet of:  PacketSocketAddress alloc  of;
      Ash of:  AshSocketAddress alloc  of;
      Econet of:  EconetSocketAddress alloc  of;
      ATMSVC of:  ATMSVCSocketAddress alloc  of;
      RDS of:  RDSSocketAddress alloc  of;
      SNA of:  SNASocketAddress alloc  of;
      IRDA of:  IRDASocketAddress alloc  of;
      PPPoX of:  PPPoXSocketAddress alloc  of;
      Wanpipe of:  WanpipeSocketAddress alloc  of;
      LLC of:  LLCSocketAddress alloc  of;
      InfiniBand of:  InfiniBandSocketAddress alloc  of;
      MPLS of:  MPLSSocketAddress alloc  of;
      CAN of:  CANSocketAddress alloc  of;
      TIPC of:  TIPCSocketAddress alloc  of;
      Bluetooth of:  BluetoothSocketAddress alloc  of;
      IUCV of:  IUCVSocketAddress alloc  of;
      RxRCP of:  RxRCPSocketAddress alloc  of;
      ISDN of:  ISDNSocketAddress alloc  of;
      Phonet of:  PhonetSocketAddress alloc  of;
      IEEE802154 of:  IEEE802154SocketAddress alloc  of;
      CAIF of:  CAIFSocketAddress alloc  of;
      Algorithm of:  AlgorithmSocketAddress alloc  of;
      NFC of:  NFCSocketAddress alloc  of;
      VSocket of:  VSocketSocketAddress alloc  of;
      KCM of:  KCMSocketAddress alloc  of;
      QIPCRouter of:  QIPCRouterSocketAddress alloc  of;
      SMC of:  SMCSocketAddress alloc  of;
      XDP of:  XDFSocketAddress alloc  of;
      "Invalid protocol number: %d!"| ERROR handle  case;
    dup Size rot SYS-GETSOCKNAME, SystemResult0  KO if  drop  then ;



enum;
