( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Enum set base module for FORCE-linux 4.19.0-5-amd64 ******

package /force/internal
import /force/intel/64/core/ForthBase

class: enumsetbase1
  requires ForthBase



  === Interface ===

  def value@ ( -- u1 )
  constructor new ( u1 -- )



  === Implementation ===

  U1 var value
  : new ( u1 )  my value! ;

class;
