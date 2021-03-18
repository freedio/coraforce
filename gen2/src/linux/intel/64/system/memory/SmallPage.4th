( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Small Page Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro
import Page

class: SmallPage extends PageBase implements Page



  === Interface ===

  512 const Maximum static                            ( Maximum size of a small entry )
  U2 val Capacity                                     ( Page capacity = number of slots per page )
  U2 val Free#                                        ( Number of free slots )
  U2 val Used#                                        ( Size of allocation table in bytes )
  create Used                                         ( Address of the allocation table )

  constructor new ( tp -- )                           ( initialize a new page for small entries of size tp )



  === Implementation ===

  : new ( tp -- )  dup 1 SmallPageMaximum within unless  1 "Invalid entry size for small page: %d"| abort  then
    dup ^ new  PageSize my #!  Used   ;  cascaded
  : Elements ( -- a )

class;
