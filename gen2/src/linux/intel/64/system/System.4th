( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux System Module for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: System  package force/intel/64/linux
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



=== Error Handling ===

: Result0 ( 0|-errno -- t | LinuxError f )            ( transform SYS-result without result to Force result )
  RESULT0, dup unlessever  swap LinuxError swap  then ;
: Result1 ( x|-errno -- x t | LinuxError f )          ( transform SYS-result with result x to Force result )
  RESULT1, dup unlessever  swap LinuxError swap  then ;



=== Process Management ===

: bye ( -- )  BYE, ;                                  ( Terminates system with exit code 0 [OK] )
: terminate ( u -- )  SYS-TERMINATE, ;                ( Terminates system with exit code u )



=== Various ===

: poll ( Polls n|-1 -- # t | LinuxError f )           ( wait for up to n ms for events in a list of polls¹ )
  swap Polls >a# swap SYS-POLL, Result1 ;             ( ¹ n=0: return instantly; n<0: wait forever )
: SigMask@ ( -- SignalSet t | LinuxError f )          ( return current signal mask of the current process )
  0  SignalSet new dup >x SignalSet >bits  0 SYS-SIGPROCMASK, SystemResult0  dup if  x@ swap  then x> free ;
: SigMask! ( SignalSet -- t | LinuxError f )          ( set SignalSet as the signal mask of the current process )
  SignalSet >bits  0  my Number 2 ( SIG_SETMASK ) SYS-SIGPROCMASK, SystemResult0 ;
: SigMask+! ( SignalSet -- t | LinuxError f )         ( add SignalSet to signal mask of the current process )
  SignalSet >bits  0  my Number 0 ( SIG_BLOCK ) SYS-SIGPROCMASK, SystemResult0 ;
: SigMask−! ( SignalSet -- t | LinuxError f )         ( remove SignalSet from signal mask of the current process )
  SignalSet >bits  0  my Number 1 ( SIG_UNBLOCK ) SYS-SIGPROCMASK, SystemResult0 ;

vocabulary;
