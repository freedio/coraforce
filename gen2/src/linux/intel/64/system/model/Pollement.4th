( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Pollement model for FORCE-linux 4.19.0-5-amd64 ******

structure: Pollement
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  U32 val FileDescr                                   ( the fd to be checked )
  U16 val Interests                                   ( a bit map of interesting events )
  U16 var Active                                      ( a bit map of active events on the fd )



  === Methods ===

static:
  : new ( IO PollEventSet -- )  ^ alloc               ( create a Pollement from a file descriptor and a poll event set )
    >bitmap my Interests!  Handle@ my FileDescr! ;


structure;
