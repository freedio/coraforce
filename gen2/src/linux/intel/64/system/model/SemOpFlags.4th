( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Semaphore Operation Flags model for FORCE-linux 4.19.0-5-amd64 ******

enumset: SemOpFlags
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  2048 :base
  symbol NoWait             ( fail if the operation would block )
  symbol UndoOnExit         ( undo the operation on exit )



  === Methods ===

enumset;
