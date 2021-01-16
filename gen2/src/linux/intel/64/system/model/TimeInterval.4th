( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux TimeInterval model for FORCE-linux 4.19.0-5-amd64 ******

structure: TimeInterval
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  MicroTime val Periodic                              ( Periodic part of the time interval: itimerinterval.it_interval )
  MicroTime val Current                               ( Current remainer of interval: itimerinterval.it_value )



  === Methods ===

construct: new ( MicroTime -- )                       ( initialize the time interval with the specified time period )
  dup my Current!  my Periodic! ;
construct: newDelayed ( MicroTime MicroTime2 -- )     ( initialize Periodic to first arg, Current to second arg )
  my Current!  my Periodic! ;
construct: newEmpty ( -- )                            ( initialize the time interval empty )
  0 MicroTime new  me new ;

class;
