( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux System Module for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: System  package force/intel/64/linux
  requires force/intel/64/core/RichForce
  uses force/intel/64/linux/SystemMacro



=== System Structures ===



=== System Calls ===

: bye ( -- )  BYE, ;                                  ( Terminates system with exit code 0 [OK] )
: terminate ( u -- )  SYS-TERMINATE, ;                ( Terminates system with exit code u )
