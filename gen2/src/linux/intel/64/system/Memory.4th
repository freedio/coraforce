( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Memory Module for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: Memory
  package force/intel/64/linux
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro

: endOf ( -- a )  -1 SYS-BRK, ;                       ( Address of first byte after allocated memory = end of memory )
: extend ( u -- a )  endOf + SYS-BRK, ;               ( extend memory by u and return new end of memory )
: shrink ( u -- a )  negate extend ;                  ( shrink memory by u and return new end of memory )

vocabulary;
