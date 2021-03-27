( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Enum set base module for FORCE-linux 4.19.0-5-amd64 ******

package /force/internal
import /force/intel/64/core/ForthBase

class: enumsetbase4
  requires ForthBase



  === Interface ===

  def value@ ( -- u4 )
  constructor new ( u4 -- )



  === Implementation ===

  U4 var value
  : new ( u4 -- )  my value! ;

class;
