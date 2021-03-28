( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Memory Reallocation Error module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/memory/trouble
import /force/intel/64/core/ForthBase
import /force/trouble/BasicException

class: MemoryReallocationError extends BasicException



  === Interface ===

  constructor new ( Severity -- )                     ( initialize instance with severity # )



  === Implementation ===

  : new ( # -- )  ^ new ;

class;
