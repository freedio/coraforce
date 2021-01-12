( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux System Module for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: System  package force/intel/64/linux
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



=== Error Handling ===

: Result0 ( 0|-errno -- t | LinuxError f )            ( transform SYS-result without result value to Force result )
  RESULT0, unlessever  >ex  then ;
: Result1 ( x|-errno -- x t | LinuxError f )          ( transform SYS-result with result value x to Force result )
  RESULT1, unlessever  >ex  then ;
: ?Result0 ( 0|-error -- ? )                          ( transform SYS-result into consulatory Force result: result OK? )
  RESULT0, 0= ;



=== Process Management ===

: bye ( -- )  BYE, ;                                  ( Terminates system with exit code 0 [OK] )
: terminate ( u -- )  SYS-TERMINATE, ;                ( Terminates system with exit code u )



=== Various ===

: poll ( Polls n|-1 -- # )  swap Polls >a#            ( wait for up to n ms for events in a list of polls¹ )
  swap SYS-POLL, Result1 ;  fallible                  ( ¹ n=0: return instantly; n<0: wait forever )
: SigMask@ ( -- SignalSet )                           ( return current signal mask of the current process )
  0  SignalSet new dup >x SignalSet >bits  0 SYS-SIGPROCMASK, SystemResult0  x> reallyKO if  free  then ;  fallible
: SigMask! ( SignalSet -- )                           ( set SignalSet as the signal mask of the current process )
  SignalSet >bits  0  my Number 2 ( SIG_SETMASK ) SYS-SIGPROCMASK, SystemResult0 ;  fallible
: SigMask+! ( SignalSet -- )                          ( add SignalSet to signal mask of the current process )
  SignalSet >bits  0  my Number 0 ( SIG_BLOCK ) SYS-SIGPROCMASK, SystemResult0 ;  fallible
: SigMask−! ( SignalSet -- )                          ( remove SignalSet from signal mask of the current process )
  SignalSet >bits  0  my Number 1 ( SIG_UNBLOCK ) SYS-SIGPROCMASK, SystemResult0 ;  fallible
: yield ( -- )  SYS-YIELD, ;                          ( ask current thread to yield in favor of other processes )


vocabulary;
