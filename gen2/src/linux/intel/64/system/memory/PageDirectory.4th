( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Page Directory Module for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro

class: PageDirectory



  === Fields ===

  Page var Top                                        ( the first page of the directory )



  === Methods ===

public:
  : init ( -- )  0 my Top ! ;

class;
