( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Command model for FORCE-linux 4.19.0-5-amd64 ******

enum: SharedMemoryCommand
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol Remove                 ( remove the segment: IPC_RMID )
  symbol SetOptions             ( set options: IPC_SET )
  symbol GetOptions             ( get options: IPC_GET )
  symbol Info                   ( information about system-wide tables: IPC_INFO )
  8 :skip
  symbol Lock                   ( ?: SHM_LOCK )
  symbol Unlock                 ( >: SHM_UNLOCK )
  symbol Stat                   ( get statistics: SHM_STAT )
  symbol ResourceInfo           ( information about system-resources used: SHM_INFO )
  symbol UserStat               ( get user-land statistics: SHM_STAT_ANY )



  === Methods ===



enumset;
