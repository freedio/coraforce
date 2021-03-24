( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Pollement model for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/model
import PollEventSet
import /force/intel/64/core/ForthBase

structure: Pollement
  requires PollEventSet
  requires ForthBase



  === Fields ===

  U4 val FileDescr                                    ( the fd to be checked )
  U2 val Interests                                    ( a bit map of interesting events )
  U2 var Active                                       ( a bit map of active events on the fd )



  === Methods ===

constructor new                                       ( create a Pollement from a file descriptor and a poll event set )



  === Implementation ===

: new ( IO PollEventSet -- )  PollEventSet bits my Interests d!  IO Handle@ my FileDescr w!  me Active w0! ;

structure;
