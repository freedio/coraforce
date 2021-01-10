( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux SigHandler model for FORCE-linux 4.19.0-5-amd64 ******

structure: SigHandler
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  Cell val Address                                    ( Address of the signal handler or action )
  U8 val Mask                                         ( Signal Mask = blocked signals during handler execution )
  U4 val Flags                                        ( Signal behavior flags )



  === Methods ===

construct: ( addr mask flags -- )  my Flags!  my Mask!  my Adress! ;

structure;
