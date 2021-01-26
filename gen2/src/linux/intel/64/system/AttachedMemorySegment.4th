( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Attached (Shared) Memory Segment Module for FORCE-linux 4.19.0-5-amd64 ******

class: AttachedMemorySegment  extends SharedMemorySegment
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U8 val Address                                      ( Address of the segment )



  === Methods ===

public:
: detach ( -- )  my Address@ SYS-SHMDT, SystemResult0 ;  fallible  ( detaches the segment )
  construct: new ( a SharedMemorySegment -- )  ^ copy  my Address! ;  cascaded

class;
