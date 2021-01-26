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

construct: new (  -- Pipe )  PipeModel new dup >x  SYS-PIPE,
  OK if  x@ PipeModelReceiver newIO my Receiver!  x@ PipeModelSender newIO my Sender!  then  xdrop ;  fallible

class;
