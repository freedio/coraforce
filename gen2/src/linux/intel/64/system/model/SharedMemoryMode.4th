( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Mode model for FORCE-linux 4.19.0-5-amd64 ******

enumset: SharedMemoryMode extends Protection
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol Create               ( create a new segment: IPC_CREAT )
  symbol Exclusive            ( fail if key already exists: IPC_EXCL )
  symbol NoWait               ( fail if the service has to wait )



  === Methods ===



enumset;
