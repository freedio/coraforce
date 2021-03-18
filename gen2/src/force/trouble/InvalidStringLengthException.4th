( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Invalid String Length Exception module for FORCE-linux 4.19.0-5-amd64 ******

package /force/trouble
import /force/intel/64/core/ForthBase
import BasicException

class: InvalidStringLengthException extends BasicException



  === Interface ===

  N8 val Length                                       ( the invalid length )
  constructor new# ( #1 #2 -- )                       ( initialize instance with severity #2 and length argument #1 )



  === Implementation ===

  : new# ( #1 #2 -- )  ^ new  my Length ! ;  cascaded

class;
