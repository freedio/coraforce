( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Semaphore Set Module for FORCE-linux 4.19.0-5-amd64 ******

class: SemaphoreSet
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  N4 val Key                    ( Key of the semaphore set )
  N4 val #Semaphores            ( Number of semaphores )
  N4 val ID                     ( Semaphore ID )



  === Methods ===

public:
  : operateOn ( SemOps -- )                           ( atomically perform the specified semaphore operations on the set )
    dup Size my ID@ SYS-SEMOP, SystemResult0 ;  fallible
  : describe ( -- ★SemaphoreSetDescriptor -- )        ( describe the semaphore set; returns the semaphore set descriptor )
    SemaphoreSetDescriptor alloc dup my ID@ 0 2 SYS-SEMCTRL4, SystemResult0  KO if  destroy  then ;  fallible
  : update ( SemaphoreSetDescriptor -- )              ( update access control information from the specified descriptor )
    my ID@ 0 1 SYS-SEMCTRL4, SystemResult0 ;  fallible
  : remove ( -- )                                     ( remove the semaphore set and fail all processes blocked on it )
    my ID@ 0 0 SYS-SEMCTRL3, SystemResult0 ;  fallible
  : Info ( -- ★SemInfo #SemSets -- )                  ( System wide information about semaphore limits + number of semaphore sets )
    SemInfo alloc dup my ID@ 0 3 SYS-SEMCTRL4, SystemResult1  KO if  destroy  then ;  fallible
  : Infos ( -- ★SemInfo #SemSets -- )                 ( like Info, but reports the aliases in the SemInfo structure )
    SemInfo alloc dup my ID@ 0 19 SYS-SEMCTRL4, SystemResult1  KO if  destroy  then ;  fallible
  : Values@ ( -- ★I4_array -- )                       ( Values of all semaphores in the set, in order )
    my #Semaphores@ 4 u* allocate dup my ID@ 0 13 SYS-SEMCTRL4, SystemResult0  KO if  free  then ;  fallible
  : #^Processes ( # -- u -- )                         ( Number u of processes waiting for semaphore # to increase )
    my ID@ swap 14 SYS-SEMCTRL3, SystemResult1 ;  fallible
  : LastPID ( # -- pid -- )                           ( PID of last process performing an action on semaphore # of the set )
    my ID@ swap 11 SYS-SEMCTRL3, SystemResult1 ;  fallible
  : Value@ ( #A -- n -- )                             ( Value of semaphore # of the set )
    my ID@ swap 12 SYS-SEMCTRL3, SystemResult1 ;  fallible
  : #0Processes ( # -- u -- )                         ( Number u of processes waiting for semaphore # to become zero )
    my ID@ swap 15 SYS-SEMCTRL3, SystemResult1 ;  fallible
  : Values! ( I4_array -- )                           ( set the values of all semaphores in the set, in order )
    my ID@ 0 17 SYS-SEMCTRL4, SystemResult0 ;  fallible
  : Value! ( u # -- )                                 ( set the value of semaphore # to u )
    my ID@ swap 16 SYS-SEMCTRL4, SystemResult0 ;  fallible
  construct: new ( key # Protection IpcMode -- )      ( initialize set key for # semaphores, Protection and IpcMode )
    2over my #Semaphores! my Key!  IpcMode >bits swap >bits + SYS-SEMGET, SystemResult0  OK if  my ID!  then ;  fallible

class;
