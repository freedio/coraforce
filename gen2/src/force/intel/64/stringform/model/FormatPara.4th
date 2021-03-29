( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The formatting parameters Module for FORCE-linux 4.19.0-5-amd64 ******


package /force/intel/64/core/model
import /force/intel/64/core/ForthBase

class: FormatPara



  === Interface ===

  U2 var Control                                      ( Control flags )
  U1 var Precision                                    ( Maximum length, or decimal length )
  U1 var ArgIndex                                     ( Argument index )
  U1 var NextArg                                      ( Index of the next argument )
  U1 var Arg#                                         ( Argument count )

  def NextArg@1−!  ( -- )                             ( decrement argument count, until 0 )
  def Control? ( # -- ? )                             ( is control bit # set? )
  def Control?− ( # -- ? )                            ( is control bit # set? and if so, turn it off )
  def Control+ ( # -- )                               ( set control bit # )
  constructor new ( -- )                              ( initialize with defaults )


  === Implementation ===

  : NextArg@1−! ( -- )  NextArg dup c@ 1− 0 max swap c! ;
  : Control? ( # -- ? )  0FH and  Control bit@ ;
  : Control?− ( # -- ? )  0FH and  Control bit@−! ;  alias Control?-
  : Control+ ( # -- )  0FH and  Control bit+! ;
  : new ( u -- )  my Arg#!  0 my Precision!  0 my ArgIndex!  0 my Control!  2 my NextArg! ;

class;
