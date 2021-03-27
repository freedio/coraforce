( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Enum set base module for FORCE-linux 4.19.0-5-amd64 ******

package /force/internal
import /force/intel/64/core/ForthBase

class: enumsetbase2
  requires ForthBase



  === Interface ===

  def value@ ( -- u2 )
  constructor new ( u2 -- )



  === Implementation ===

  U2 var value
  : new ( u2 -- ) my value! ;

class;
