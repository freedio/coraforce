( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The String module for FORCE-linux 4.19.0-5-amd64 ******

package /force/core
import /force/intel/64/core/ForthBase
import /force/trouble/InvalidStringLengthException

class: String  requires ForthBase



  === Interface ===

  U8 val Length                                       ( Length of the character array )
  cell val Elements                                   ( Address of the allocated character array )
  constructor new$ ( $ -- )                           ( initialize instance from counted string $ )
  destructor destroy



  === Implmentation ===

public:
  : new$ ( $ -- )
    count -1 ?= if  InvalidStringLengthException new FATAL raise  then
    dup my Length !  dup U4 u* allocate Elements !
    0 udo  c$@++  -1 ?= if  InvalidStringCharacterException new# FATAL raise  then
    ; fallible
  : destroy my Elements @ free ;

class;
