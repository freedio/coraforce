( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Pipe Module for FORCE-linux 4.19.0-5-amd64 ******

class: Pipe
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  IO val Receiver                                     ( Receiving end of the pipe )
  IO val Sender                                       ( Sending end of the pipe )



  === Methods ===

public:

construct: (  -- Pipe t | LinuxError f )  PipeModel new dup >x  SYS-PIPE,
  dup if  x@ PipeModelReceiver IO new my Receiver!  x@ PipeModelSender IO new my Sender!  swap  then  xdrop ;

class;
