( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Enum set base module for FORCE-linux 4.19.0-5-amd64 ******

package /force/internal
import /force/intel/64/core/ForthBase

class: enumsetbase8
  requires ForthBase



  === Interface ===

  def value@ ( -- u8 )
  constructor new ( u8 -- )



  === Implementation ===

  U8 var value
  : new ( u8 -- )  my value! ;

class;
