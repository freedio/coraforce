( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Page Array Module for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro

class: PageArray



  === Fields ===

  create Pages  512 cells zallot                      ( array of 512 page pointers, initialized to all 0 )



  === Methods ===

public:
  : TopPage@ ( # -- #p )  my Pages@ swap cells + @ ;  ( Number #p of Page # in my pages )
  : TopPage! ( #p # -- )  my Pages@ swap cells + ! ;  ( store #p in Page # of my pages )
  : init ( -- ) ;

class;
