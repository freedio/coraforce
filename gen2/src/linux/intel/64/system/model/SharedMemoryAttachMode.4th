( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Attach Mode model for FORCE-linux 4.19.0-5-amd64 ******

U2 enumset: SharedMemoryAttachMode extends Protection
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  12 :base
  symbol ReadOnly             ( prevent write access to segment: SHM_RDONLY )
  symbol RoundDown            ( round down attachment address to SHMLBA: SHM_RND )
  symbol TakeOver             ( take over the region on attach: SHM_REMAP )
  symbol Executive            ( enable execute access to segment: SHM_EXEC )



  === Methods ===



enumset;
