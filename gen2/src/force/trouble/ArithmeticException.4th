( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Arithmetic Exception module for FORCE-linux 4.19.0-5-amd64 ******

package force/trouble
import /force/intel/64/core/ForthBase
import BasicException

class: ArithmeticException extends StandardException



  === Fields ===



  === Methods ===

public:
  construct: new$ ( $ # -- )  ^ new$ ;                ( initialize instance with severity # and message $ )

class;
