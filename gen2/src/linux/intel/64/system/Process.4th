( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Module for FORCE-linux 4.19.0-5-amd64 ******

class: Process
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  N4 val ID                                           ( the process identifier )



  === Methods ===

public:
  construct: new ( pid -- )  my ID! ;
  : fork ( -- Process|0 )                             ( create a new process; returns the child Process, or 0 to the child )
    my ID@ SYS-FORK, SystemResult1  OK if  dup if  Process new  then  then ;  fallible
  : vfork ( -- Process|0 )                            ( create a new process in the parent's address space and pause the parent¹ )
    ( ¹ use only when you know exactly what you do )
    my ID@ SYS-VFORK, SystemResult1  OK if  dup if  Process new  then  then ;  fallible
  : kill ( Signal -- )                                ( send Signal to the process )
    Signal >bits my ID@ SYS-KILL, SystemResult0 ;  fallible
  construct: current ( -- )  SYS-GETPID, my ID! ;     ( initialize with current process ID )

class;
