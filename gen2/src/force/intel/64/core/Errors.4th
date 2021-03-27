( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The error handling vocabulary for FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/core
import ForthBase
import /force/trouble/Exception
import /linux/intel/64/system/SystemMacro

vocabulary: Errors
  requires Exception
  requires ForthBase

  create EXSTACK  256 cells allot                     ( The exception stack growing upwards with space for 256 entries )
  variable EXSP                                       ( The exception stack pointer )

  : >ex ( x -- )  !Exception EXSP @ !  EXSP cell+! ;  ( push x on the exception stack )
  : ex> ( -- x )  EXSP cell−!  EXSP @ @ ;             ( pop x from exception stack )
  : #ex ( # -- x )  cells EXSTACK + @ ;               ( return #'th stack entry --- no limits checked! )
  : exdrop ( -- )  EXSP @ cell− EXSTACK max EXSP ! ;  ( remove last error, if there was one )
  : exdepth ( -- # )  EXSP @ EXSTACK − cellu/ ;       ( number of entries on the exception stack )

  : OK ( -- ? )  exdepth 0= ;                         ( check if everything OK, i.e. no exceptions occurred at all )
  : reallyOK ( -- ? )                                 ( check if really everything OK, i.e. no /severe/ exception occurred )
    0 exdepth ?dupifever  0 udo  i #ex Severity@ max  uloop  then  0= ;
  : KO ( -- ? )  exdepth 0≠ ;                         ( check if an exception occurred [could also we only a warning...!] )
  : reallyKO ( -- ? )                                 ( check if something went awry, i.e. a /severe/ exception occurred )
    0 exdepth ?dupifever  0 udo  i #ex Severity@ max  uloop  then  0≠ ;
  : ?abort ( # -- )  ?dupifever  SYS-TERMINATE, then ; ( abort if error severity # is not 0 )
  : fail ( -- )  exdepth ?dupifever                   ( if at least one exception occurred: print all exceptions and abort  )
    0 swap 0 udo  ex> dup Severity@ rot max  swap eprint  uloop  ?abort  then ;

  === Error Handling ===

  : Result0 ( 0|-errno -- -- LinuxError )               ( transform SYS-result without result value to Force result )
    RESULT0, unlessever  >ex  then ;
  : Result1 ( x|-errno -- x -- LinuxError )             ( transform SYS-result with result value x to Force result )
    RESULT1, unlessever  >ex  then ;
  : ?Result0 ( 0|-error -- ? )                          ( transform SYS-result into consulatory Force result: result OK? )
    RESULT0, 0= ;

  init: ( @initstr -- @initstr )  EXSTACK EXSP ! ;

vocabulary;
