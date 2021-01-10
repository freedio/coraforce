( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Memory Area Module for FORCE-linux 4.19.0-5-amd64 ******

class: MemoryArea
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  cell val Address                                    ( Start address of the memory mapped area )
  U8 val Length                                       ( Length of the area )



  === Methods ===

public:
  : protect ( MemProtection -- t | LinuxError f )     ( protect memory area with MemProtection )
    MemProtection >bits my Address my Length rot SYS-MPROTECT, SystemResult0 ;

construct: ( a # -- MemoryArea )                      ( initialize MemoryArea with address a and length # )
    my Length!  my Address! ;

class;
