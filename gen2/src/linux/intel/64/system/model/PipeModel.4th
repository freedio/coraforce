( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Pipe model model for FORCE-linux 4.19.0-5-amd64 ******

structure: PipeModel
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  U4 val Receiver                                     ( Receiving end of the pipe )
  U4 val Sender                                       ( Sending end of the pipe )



  === Methods ===

construct: ( recv sndr -- PipeModel )  my Sender!  my Receiver! ;

structure;
