( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Semaphore Set Descriptor model for FORCE-linux 4.19.0-5-amd64 ******

structure: SemaphoreSetDescriptor
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  IpcAccessControl val AccessControl        ( Ownership and Access control )
  N8 val LastOp                             ( Time of last operation )
  N8 val Created                            ( Time of creation )
  U8 val #Semaphores                        ( Number of semaphores in the set )



  === Methods ===


structure;
