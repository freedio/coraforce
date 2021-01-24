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
protected:
  construct: copy ( SharedMemorySegment -- )
public:
  : attach ( SharedMemoryAttachMode -- AttachedMemorySegment -- ) ( attach the segment to any free address with the specified mode )
    SharedMemoryAttachMode >bits 0 my ID@ rot SYS-SHMAT, SystemResult1  OK if  me AttachedMemorySegment new  then ;  fallible
  : attachAt ( a SharedMemoryAttachMode -- AttachedMemorySegment -- ) ( attach the segment to address a¹ with the specified mode )
    ( ¹ either a MUST be page-aligned, or RoundDown must be set in SharedMemoryAttachMode )
    SharedMemoryAttachMode >bits my ID@ swap SYS-SHMAT, SystemResult1  OK if  me AttachedMemorySegment new  then ;  fallible
  : Status@ ( -- ★SharedMemoryDescriptor -- )         ( Status of the segment as a SharedMemoryDescriptor )
    SharedMemoryDescriptor alloc my ID@ SharedMemoryCommand:Stat SYS-SHMCTL, SystemResult0  KO if  destroy  then ;  fallible
  : Status! ( SharedMemoryDescriptor -- )             ( Update status of the segment from the specified SharedMemoryDescriptor )
    my ID@ SharedMemoryCommand:Set SYS-SHMCTL, SystemResult0 ;  fallible
  : Limits@ ( -- ★SharedMemoryInfo1 u -- )            ( Information about system-wide shm limits and parameters¹ )
    ( ¹ u = index of the highest used entry in kernel array of shared memory pages )
    SharedMemortInfo1 alloc my ID@ SharedMemoryCommand:Info SYS-SHMCTL, SystemResult1  KO if  destroy  then ;
  construct: new ( # Protection -- )                  ( create brand-new exclusive shm seg of size # with specified Protection )
    0 -rot  SharedMemoryModeCreate SharedMemoryModeExclusive +  me _init SEP ;  fallible
  construct: find ( key # Protection -- )             ( find existing shm seg with given key, size and protection, or create one )
    SharedMemoryModeCreate  me _init SEP ;  fallible
  construct: reuse ( key # Protection -- )            ( find existing shm seg with given key, size and protection, or fail )
    0  me _init SEP ;  fallible
  destruct: 0 my ID@ SharedMemoryCommand:Remove SYS-SHMCTL, SystemResult0 ;  fallible

static:
  : Resource@ ( # -- ★SharedMemoryInfo1 -- )          ( Information about system-wide shm entry # )
    SharedMemortInfo1 alloc swap SharedMemoryCommand:ResourceInfo SYS-SHMCTL, SystemResult0  KO if destroy  then ;
  : UserStat@ ( # -- ★SharedMemoryInfo2 -- )          ( Information about system-wide shm entry # )
    SharedMemortInfo2 alloc swap SharedMemoryCommand:UserStat SYS-SHMCTL, SystemResult0  KO if destroy  then ;

class;
