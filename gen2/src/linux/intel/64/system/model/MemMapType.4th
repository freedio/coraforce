( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux MemMapType model for FORCE-linux 4.19.0-5-amd64 ******

enum: MemMapType
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  1 :base
  symbol Shared               ( shared memory map, visible also to other processes: MAP_SHARED )
  symbol Private              ( private memory area )
  symbol SharedValidate       ( shared memory map validating mode: MAP_SHARED_VALIDATE )



  === Methods ===



enum;
