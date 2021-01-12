( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Memory Area Module for FORCE-linux 4.19.0-5-amd64 ******

class: MemoryArea
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

private:
  cell var Address                                    ( Start address of the memory mapped area )
  U8 var Length                                       ( Length of the area in bytes )
static:
  4096 const PAGE#                                    ( Linux memory page size )



  === Methods ===

private:
  : mkbytearray ( -- a # )  my Length@ PAGE# u→| PAGE# u/ dup allocate ;
  : >bits ( a # -- BitSet a' )  dup BitSet new -rot 0 udo  c@++ if  swap BitSet+! swap  then  loop ;
public:
  : protect ( MemProtection -- )                      ( protect memory area with MemProtection )
    MemProtection >bits my Address@ my Length@ rot SYS-MPROTECT, SystemResult0 ;  fallible
  : ResidentPages ( -- BitSet )                       ( Bit set of pages resident in core )
    mkbytearray over my Address@ my Length@ rot SYS-MINCORE, SystemResult0  OK if  >bits  dup  then  2drop ;  fallible


construct: new ( a # -- MemoryArea )                  ( initialize MemoryArea with address a and length # )
    my Length!  dup PAGE# and if  "Address %a not aligned to page boundary!" format ERROR raise then  my Address! ;  fallible

class;
