( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Page Directory Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro
import Page

class: PageDirectory
  requires Page
  requires ForthBase



  === Interface ===

  cell var Top                                        ( the first page of the directory )



  === Implementation ===

  : init ( -- )  0 my Top ! ;

class;
