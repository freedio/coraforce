( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Mapped Memory Area Module for FORCE-linux 4.19.0-5-amd64 ******

class: MappedMemoryArea extends linux/intel/64/system/MemoryArea
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U1 val Mapped                                       ( 0: unmapped area, ≠0: mapped area )



  === Methods ===

public:
  : unmap ( -- t | LinuxError f )                     ( unmap the memory area, if it was mapped )
    I’m Mapped if  my Address my Length SYS-MUNMAP, SystemError0 ;

construct: ( a # ? -- MemoryArea )                    ( initialize new MappedMemoryArea with address a, length # and mapped ? )
    I’m Mapped!  ^ _init ; cascaded ( ← includes call to super constructor )
discard: ( -- t | LinuxError f )  unmap ;             ( destroy the mapped memory area )

class;
