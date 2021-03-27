( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Signal Set model for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/model

U4 enumset: SignalSet ( of Signal --- doesn't work yet )



  === Interface ===

  symbol Hangup                                       ( Hangup on controlling terminal/death of controlling process: SIGHUP )
  symbol Interrupt                                    ( Interrupt from keyboard: SIGINT )
  symbol Quit                                         ( Quit from keyboard: SIGQUIT )
  symbol IllegalInstruction                           ( Illegal Instruction: SIGILL )
  symbol Trap                                         ( Trace/breakpoint trap: SIGTRAP )
  symbol Abort  alias IOT                             ( Abort signal from abort[3] or IOT trap: SIGABRT )
  symbol Baddress  alias BusError                     ( Bus error [bad address]: SIGBUS )
  symbol FloatingPointException                       ( Floating-point exception: SIGFPE )
  symbol Kill                                         ( Kill signal: SIGKILL )
  symbol User1                                        ( User-defined signal 1: SIGUSR1 )
  symbol SegmentationValidation                       ( Invalid memory reference: SIGSEGV )
  symbol User2                                        ( User-defined signal 2: SIGUSR2 )
  symbol BrokenPipe                                   ( Broken pipe: write to pipe with no readers; see pipe[7]: SIGPIPE )
  symbol Alarm                                        ( Timer signal from alarm[2]: SIGALRM )
  symbol Terminate                                    ( Termination signal: SIGTERM )
  symbol CoprocStackFault                             ( Stack fault on coprocessor [unused]: SIGSTKFLT )
  symbol ChildEvent                                   ( Child process stopped or terminated: SIGCHLD )
  symbol Continue                                     ( Continue if stopped: SIGCONT )
  symbol Stop                                         ( Stop process: SIGSTOP )
  symbol TermStop                                     ( Stop typed at terminal: SIGTSTP )
  symbol BgdTerminalInput                             ( Terminal input for background process: SIGTTIN )
  symbol BgdTerminalOutput                            ( Terminal output for background process: SIGTTOU )
  symbol CPUTimeLimitExceeded                         ( CPU time limit exceeded; see setrlimit[2]: SIGXCPU )
  symbol FileLimitExceeded                            ( File size limit exceeded; see setrlimit[2]: SIGXFSZ )
  symbol VirtAlarm                                    ( Virtual alarm clock: SIGVTALRM )
  symbol ProfilingTimerExpired                        ( Profiling timer expired: SIGPROF )
  symbol WindowResize                                 ( Window resize signal: SIGWINCH )
  symbol I/OPossible  alias Poll                      ( I/O now possible: SIGIO )
  symbol PowerFailure                                 ( Power failure: SIGPWR )
  symbol BadSystemCall                                ( Bad system call; see also seccomp[2]: SIGSYS )



  === Implementation ===

enumset;
