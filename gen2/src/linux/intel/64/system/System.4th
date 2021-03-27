( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux System Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system

import SystemMacro
import model/SignalSet
import model/NanoTime
import memory/Memory
import /force/intel/64/core/Errors
import /force/intel/64/core/ForthBase

vocabulary: System
  requires Errors
  requires SignalSet
  requires ForthBase
  requires Memory



=== Process Management ===

: bye ( -- )  BYE, ;                                  ( Terminates system with exit code 0 [OK] )
: terminate ( u -- )  SYS-TERMINATE, ;                ( Terminates system with exit code u )



=== Various ===

: SigMask@ ( -- SignalSet )                           ( return current signal mask of the current process )
  0 SignalSet new dup >x SignalSet value@  0 SYS-SIGPROCMASK, Result0  x> reallyKO if  free  then ;  fallible
: SigMask! ( SignalSet -- )                           ( set SignalSet as the signal mask of the current process )
  SignalSet value@  0  my Number 2 ( SIG_SETMASK ) SYS-SIGPROCMASK, Result0 ;  fallible
: SigMask+! ( SignalSet -- )                          ( add SignalSet to signal mask of the current process )
  SignalSet value@  0  my Number 0 ( SIG_BLOCK ) SYS-SIGPROCMASK, Result0 ;  fallible
: SigMask−! ( SignalSet -- )                          ( remove SignalSet from signal mask of the current process )
  SignalSet value@  0  my Number 1 ( SIG_UNBLOCK ) SYS-SIGPROCMASK, Result0 ;  fallible
: yield ( -- )  SYS-YIELD, ;                          ( ask current thread to yield in favor of other processes )
: pause ( -- )  SYS-PAUSE, ;                          ( wait for a signal )
: alarm ( u -- )                                      ( set alarm to u seconds )
  SYS-ALARM, Result1 drop ;  fallible
: nanosleep ( NanoTime -- NanoTime' )                 ( puts caller to sleep for the specified time; signal may awake it earlier )
  0 NanoTime new tuck  SYS-NANOSLEEP, Result0  KO if drop  then ; fallible
: setAlarm ( u -- )                                   ( set alarm to u seconds )
  SYS-ALARM, Result1 drop ;  fallible
: cancelAlarm ( -- u )                                ( cancel alarm previously set, report number of seconds until SIGALRM )
  0 SYS-ALARM, Result1 ;  fallible
: Name ( -- KernelInfo )                              ( return system kernel information )
  newKernelInfo dup SYS-UNAME, Result0  KO if  drop  then ;  fallible

vocabulary;
