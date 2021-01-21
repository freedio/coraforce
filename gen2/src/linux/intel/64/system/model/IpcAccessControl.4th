( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux IPC Access Control model for FORCE-linux 4.19.0-5-amd64 ******

structure: IpcAccessControl
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  N4 val Key                    ( Key supplied to semget )
  U4 val OwnerUID               ( Effective UID of owner )
  U4 val OwnerGID               ( Effective GID of owner )
  U4 val CreatorUID             ( Effective UID of creator )
  U4 val CreatorGID             ( Effective GID of creator )
  U4 val Permissions            ( Permissions, style of Protection )
  U4 val Sequence#              ( Sequence number )



  === Methods ===


structure;
