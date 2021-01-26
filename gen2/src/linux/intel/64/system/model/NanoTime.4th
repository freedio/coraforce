( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux NanoTime model for FORCE-linux 4.19.0-5-amd64 ******

class: NanoTime
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  N8 val Seconds                                      ( Seconds since the epoch )
  N8 val Nanos                                        ( Nanoseconds within the second )



  === Methods ===

construct: new ( n -- )  my Seconds!  0 my Nanos! ;   ( initialize NanoTime with just n seconds )
construct: new+ ( n1 n2 -- )  my Nanos!  my Seconds! ;  ( initialize NanoTime with n1 seconds and n2 ns )

class;
