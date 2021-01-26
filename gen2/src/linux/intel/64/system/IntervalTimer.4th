( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux per-process IntervalTimer Module for FORCE-linux 4.19.0-5-amd64 ******

class: IntervalTimer
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  TimerType val Type                                  ( Type of the interval timer )



  === Methods ===

public:
  : lap ( -- TimeInterval )                           ( Current timer value )
    newEmptyTimeInterval dup my Type@ SYS-GETITIMER, SystemResult0  KO if  drop  then ;  fallible
  : start ( TimeInterval -- )                         ( start the timer with the specified interval )
    0 my Type@ SYS-SETITIMER, SystemResult0 ;  fallible
  : restart ( TimeInterval:t1 -- TimeInterval:t2 )    ( restart timer with t1, reports lap of previous interval )
    newEmptyTimeInterval tuck my Type@ SYS-SETITIMER, SystemResult0  KO if  drop  then ;  fallible

class;
