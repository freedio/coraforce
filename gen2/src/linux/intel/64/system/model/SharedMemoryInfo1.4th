( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Information model for FORCE-linux 4.19.0-5-amd64 ******

structure: SharedMemoryInfo1
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  U8 val MaximumSegment#          ( Maximum segment size: shminfo.shmmax )
  U8 val MinimumSegment#          ( Minimum segment size [always 1]: shminfo.shmmin )
  U8 val Maximum#Segments         ( Maximum number of segments: shminfo.shmmni )
  U8 val Maximum#Segments/Process ( Maximum number of segments attachable to 1 process: shminfo.shmseg )
  U8 val Maximum#Pages            ( Maximum number of shared pages memory, system-wide: shminfo.shmall )



  === Methods ===


structure;
