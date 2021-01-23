( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Segment Module for FORCE-linux 4.19.0-5-amd64 ******

class: SharedMemorySegment
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U8 val Key                                          ( Key of the segment )
  U8 val Length                                       ( Length of the segment )
  U4 val ID                                           ( Segment ID )
  SharedMemoryMode val Mode                           ( Protection and mode flags )



  === Methods ===

private:
  : _init ( key # Protection fl -- )  swap >bits + SharedMemoryMode new my Mode!  my Length!  my Key!
    my Key@ my Length@ my Mode@ SYS-SHMGET, SystemResult1  OK if  my ID!  then ;  fallible
public:
  : 
  construct: new ( # Protection -- )                  ( create brand-new exclusive shm seg of size # with specified Protection )
    0 -rot  SharedMemoryModeCreate SharedMemoryModeExclusive +  me _init SEP ;  fallible
  construct: find ( key # Protection -- )             ( find existing shm seg with given key, size and protection, or create one )
    SharedMemoryModeCreate  me _init SEP ;  fallible
  construct: reuse ( key # Protection -- )            ( find existing shm seg with given key, size and protection, or fail )
    0  me _init SEP ;  fallible

class;
