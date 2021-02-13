( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Page Interface for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro

interface: Page

  def Successor@ ( -- Page )                          ( Next page of the same type )
  def Type@ ( -- u )                                  ( Page type: 0 = large, 511 = huge, 1..511 = large )
  def Full? ( -- ? )                                  ( check if the page is full )
  def Full+ ( -- )                                    ( declare the page full )
  def Full− ( -- )  alias Full-                       ( declare the page not full )
  def Elements ( -- a )                               ( Address of the element [array] )

interface;