( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Internet4SocketAddress model for FORCE-linux 4.19.0-5-amd64 ******

class: Internet4SocketAddress
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  U2 val AddressFamily
  U2 val Port
  U4 val Address
  U8 val Padding



  === Methods ===

construct: new ( address port -- )  my Port!  my Address!  Internet4 my AddressFamily! ;

class;
