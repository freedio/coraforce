( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Mapped Memory Area Module for FORCE-linux 4.19.0-5-amd64 ******

class: MappedMemoryArea extends linux/intel/64/system/MemoryArea
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U1 val Mapped                                       ( 0: unmapped area, ≠0: mapped area )
  U1 val SyncOnUnmap                                  ( 0: don't, 1: asynchronously, 2: synchronously )



  === Methods ===

public:
  : resizeFixed ( # -- )                              ( resizes the mapped area to size #, without moving it )
    I’m Mapped@ if  my Address@  my Length@  0  4 roll  0  SYS-MREMAP, SystemResult0  else  my Length!  then ;  fallible
  : resizeRelocatable ( # -- )                        ( resizes the mapped area to size #, possibly relocating it )
    I’m Mapped@ if
      my Address@  my Length@  0  4 roll  1  SYS-MREMAP, SystemResult1  OK if  swap  my Address!  then
      else  my Length!  then ;  fallible
  : synch ( -- )  I’m Mapped@ if                      ( synchronize with underlying storage, waiting for it )
    my Address@ my Length@ 4 SYS-MSYNC, SystemResult0  then ;  fallible
  : asynch ( -- )  I’m Mapped@ if                     ( synchronize with underlying storage in the background )
    my Address@ my Length@ 1 SYS-MSYNC, SystemResult0  then ;  fallible
  : unmap ( -- )                                      ( unmap the memory area, if it was mapped )
    I’m Mapped@ if
      SyncOnUnmap@ case:
        1 of:  asynch  of;
        2 of:  synch  of;
        case;
      my Address@  my Length@ SYS-MUNMAP, SystemResult0 OK if  my Mapped 0!  then ;  fallible

construct: new ( a # ? -- MemoryArea )                ( initialize new MappedMemoryArea with address a, length # and mapped ? )
    I’m Mapped@!  ^ _init ; cascaded ( ← includes call to super constructor )
destroy: ( -- )  unmap ;  fallible                    ( destroy the mapped memory area )

class;
