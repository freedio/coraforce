( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux PID model for FORCE-linux 4.19.0-5-amd64 ******

class: PID
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  N4 val numeric                                      ( numeric value of the process ID )



  === Methods ===

construct: new ( -- )  SYS-GETPID, my numeric!        ( initialize with current process ID )

class;
