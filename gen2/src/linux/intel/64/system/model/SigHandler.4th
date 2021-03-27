( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux SigHandler model for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/model

import /force/intel/64/core/ForthBase

structure: SigHandler
  requires ForthBase



  === Interface ===

  Cell val Address                                    ( Address of the signal handler or action )
  U8 val Mask                                         ( Signal Mask = blocked signals during handler execution )
  U4 val Flags                                        ( Signal behavior flags )

  constructor new ( addr mask flags -- )              ( initialize a new instance )



  === Implementation ===

  : new ( addr mask flags -- )  my Flags !  my Mask !  my Address ! ;

structure;
