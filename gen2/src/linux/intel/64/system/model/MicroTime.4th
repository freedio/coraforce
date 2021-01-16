( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux MicroTime model for FORCE-linux 4.19.0-5-amd64 ******

structure: MicroTime
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  N4 val Seconds                                      ( Seconds since the epoch )
  N4 val Micros                                       ( Microseconds within the second )



  === Methods ===

construct: new ( n -- )  my Seconds!  0 my Micros! ;  ( initialize MicroTime with just seconds )
construct: new+ ( n1 n2 -- )  my Micros!  my Seconds! ;  ( initialize MicroTime with seconds and μs )

structure;
