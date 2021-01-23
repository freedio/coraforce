( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux IPC Permissions model for FORCE-linux 4.19.0-5-amd64 ******

structure: IpcPermissions
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  U8 val Key                                ( Key [passed to shmget] )
  U4 val OwnerUID                           ( Owner user id )
  U4 val OwnerGID                           ( Owner group id )
  U4 val CreatorUID                         ( Creator user id )
  U4 val CreatorGID                         ( Creator group id )
  U2 val Mode                               ( Permissions + DEST + Locked )
  U2 val Sequence#                          ( Sequence number )



  === Methods ===


structure;
