( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Signal Module for FORCE-linux 4.19.0-5-amd64 ******

class: Signal
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/System
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  U1 val Number                                       ( Signal Number )



  === Methods ===

  : Action@ ( -- SignalHandler t | LinuxError f )     ( return the handler for this signal )
    0  SigHandler new dup >x  my Number cell SYS-SIGACTION, SystemResult0  dup if  x@ swap  then  xdrop ;
  : Action! ( SignalHandler -- t | LinuxError f )     ( set the handler for this signal )
    SignalHandler>sighandler 0 my Number cell SYS-SIGACTION, SystemResult0 ;

class;
