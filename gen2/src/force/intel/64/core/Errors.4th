( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The error handling vocabulary for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: Errors  package force/intel/64/core
  requires force/intel/64/core/RichForce
  requires force/intel/64/core/Exception
  uses linux/intel/64/system/SystemMacro

create EXSTACK  256 cells allot                       ( The exception stack growing upwards with space for 256 entries )
EXSTACK =variable EXSP                                ( The exception stack pointer )

: >ex ( x -- )  !Exception EXSP @ !  EXSP cell+! ;    ( push x on the exception stack )
: ex> ( -- x )  EXSP cell−!  EXSP @ @ ;               ( pop x from exception stack )
: #ex ( # -- x )  cells EXSTACK + @ ;                 ( return #'th stack entry --- no limits checked! )
: exdrop ( -- )  EXSP @ cell− EXSTACK max EXSP ! ;    ( remove last error, if there was one )
: exdepth ( -- # )  EXSP @ EXSTACK − cellu/ ;         ( number of entries on the exception stack )

: OK ( -- ? )  exdepth 0= ;                           ( check if everything OK, i.e. no exceptions occurred at all )
: reallyOK ( -- ? )                                   ( check if really everything OK, i.e. no /severe/ exception occurred )
  0 exdepth ?dupifever  0 udo  i #ex Severity@ max  loop  0= ;
: KO ( -- ? )  exdepth 0≠ ;                           ( check if an exception occurred [could also we only a warning...!] )
: reallyKO ( -- ? )                                   ( check if something went awry, i.e. a /severe/ exception occurred )
  0 exdepth ?dupifever  0 udo  i #ex Severity@ max  loop  0≠ ;
: ?abort ( # -- )  ?dupifever  ABORT @ execute then ; ( abort if error severity # is not 0 )
: fail ( -- )  exdepth ?dupifever                     ( if at least one exception occurred: print all exceptions and abort  )
  0 swap 0 udo  ex> dup Severity@ rot max  swap eprint  loop  ?abort  then ;

vocabulary;
