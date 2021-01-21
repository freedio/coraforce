( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Semaphore Set Module for FORCE-linux 4.19.0-5-amd64 ******

class: SemaphoreSet
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  N4 val Key                    ( Key of the semaphore set )
  N4 val #SemaphoreSet          ( Number of semaphores )
  N4 val ID                     ( Semaphore ID )



  === Methods ===

public:
  : increase ( ... )
  construct: new ( key # Protection IpcMode -- )  2over my #SemaphoreSet! my Key!
    IpcMode >bits swap >bits + SYS-SEMGET,  OK if  my ID!  then ;  fallible

class;
