( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Signal Behavior model for FORCE-linux 4.19.0-5-amd64 ******

U4 enumset: SignalBehavior
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol NoChildStopResume                              ( Don't send SIGCHLD when children stop: SA_NOCLDSTOP )
  symbol NoChildWait                                    ( Don't create zombie on child death: SA_NOCLDWAIT )
  symbol UseInfoCall                                    ( Invoke signal handler with three args instead of one: SA_SIGINFO )
  25 :skip
  symbol Restart                                        ( Restart syscall on signal return: SA_RESTART )
  symbol Interrupt                                      ( Historical no-op: SA_INTERRUPT )
  symbol NoDefer                                        ( Don't automatically block signal when handler executed: SA_NODEFER )
  symbol ResetHandler  alias AlternateStack             ( Reset to default handler on entry to handler: SA_RESETHAND )
                                                        ( AlternateStack: Use signal stack from Restorer )


  === Methods ===



enumset;
