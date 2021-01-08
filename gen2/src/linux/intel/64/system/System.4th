( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux System Module for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: System  package force/intel/64/linux
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



=== System Structures ===



=== Process Management ===

: bye ( -- )  BYE, ;                                  ( Terminates system with exit code 0 [OK] )
: terminate ( u -- )  SYS-TERMINATE, ;                ( Terminates system with exit code u )



=== Various ===

: poll ( Polls n|-1 -- # t | err f )                  ( wait for up to n ms for events in a list of polls¹ )
  swap Polls >a# swap SYS-POLL, RESULT1, ;            ( ¹ n=0: return instantly; n<0: wait forever )




vocabulary;
