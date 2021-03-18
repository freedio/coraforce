( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Page Directory Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro

class: PageDirectory



  === Interface ===

  Page var Top                                        ( the first page of the directory )



  === Implementation ===

public:
  : init ( -- )  0 my Top ! ;

class;
