( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Standard Exception module for FORCE-linux 4.19.0-5-amd64 ******

package /force/trouble
import /force/intel/64/core/ForthBase
import /force/core/String
import Exception

class: StandardException extends BasicException



  === Interface ===

  String val Message                                  ( how severe the exception is )
  constructor new ( $ # -- )                          ( initialize instance with severity # and message $ )


  === Implementation ===

  : new ( $ # -- )  ^ new  my Message ! ;

class;
