( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Error Module for FORCE-linux 4.19.0-5-amd64 ******

class: LinuxError
  package linux/intel/64/system
  requires force/intel/64/core/RichForce



  === Fields ===

  U8 val Code                                         ( the Linux error code )



  === Methods ===

construct: new ( errno -- LinuxError )  my Code! ;    ( creates a LinuxError with the specified linux errno )

class;
