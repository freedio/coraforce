( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux IPC Mode model for FORCE-linux 4.19.0-5-amd64 ******

U2 enumset: IpcMode
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  9 :base
  symbol Create               ( create key if key does not exist: IPC_CREAT )
  symbol Exclusive            ( fail if key exists: IPC_EXCL )
  symbol NoWait               ( fail if system has to wait )



  === Methods ===



enumset;
