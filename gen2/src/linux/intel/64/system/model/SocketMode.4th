( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux SocketMode model for FORCE-linux 4.19.0-5-amd64 ******

U1 enumset: SocketMode
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol NonBlocking                                    ( Nonblocking socket )
  symbol CloseOnExecute                                 ( Close socket on EXECVE )



  === Methods ===

public:
  : >openbits ( -- %u )  0 my Value@                    ( convert enumset to OpenMode-bitmask )
    NonBlocking ?bit? if  swap OpenMode NonBlocking or swap  then
    CloseOnExecute ?bit? if  swap OpenMode CloseOnExecute or swap  then
    drop ;

enumset;
