( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux NanoTime model for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64/system/model

import /force/intel/64/core/ForthBase

class: NanoTime
  requires ForthBase



  === Fields ===

  N8 val Seconds                                      ( Seconds since the epoch )
  N8 val Nanos                                        ( Nanoseconds within the second )

  constructor new ( n -- )                            ( initialize nanotime with just n seconds )
  constructor new+ ( n1 n2 -- )                       ( initialize nanotime with n1 seconds and n2 ns )



  === Methods ===

: new+ ( n1 n2 -- )  my Nanos q!  my Seconds q! ;
: new ( n -- )  0 swap new+ ;

class;
