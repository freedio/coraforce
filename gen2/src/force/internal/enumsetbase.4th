( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Enum set base module for FORCE-linux 4.19.0-5-amd64 ******

package /force/internal
import /force/intel/64/core/ForthBase

class: enumsetbase
  requires ForthBase



  === Interface ===

  def bits                                            ( The enumset as a bitmap )



  === Implementation ===

  : bits ( this -- u )  size my u#@ ;

class;
