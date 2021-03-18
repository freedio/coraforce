( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Page Base Module for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro

class: PageBase



  === Interface ===

  4096 const Size static                              ( System wide memory page size )
  Page var Successor                                  ( Next page of the same type, or 0 )
  U1 val Type                                         ( Page type [incl. bit 1 of Flags]: 0 = large, 511 = huge, 1..511 = large )
  PageFlags object Flags                              ( Page flags )
  def Type@ ( -- tp )                                 ( Type of Page )
  def Full? ( -- ? )                                  ( whether the page is full, i.e. cannot accept more entries )
  def Full+ ( -- )                                    ( mark page full )
  def Full− ( -- )                                    ( mark page not full )



  === Implementation ===

  construct: new ( tp -- )  dup 255 and my Type c!  8 u>> 1 and my Flags c! ;
  : Type@ ( -- tp )  my Type c@  my Flags 1 and 8 u<< + ;
  : Full? ( -- ? )  my Flags 7 bit@ ;
  : Full+ ( -- )  my Flags 7 bit+! ;
  : Full− ( -- )  my Flags 7 bit−! ;

class;
