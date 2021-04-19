( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The FORTH extension vocabulary of FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/core
import ForthBase
import ../macro/CoreMacro
import /force/trouble/ArithmeticException
import /force/trouble/TypecastException

vocabulary: ForthExt
  requires ForthBase
  requires ArithmeticException
  requires TypecastException



=== Exception Handling ===



=== Error Handling ===

--- Error Handling Constants ---
0 constant NORMAL
1 constant WARNING
2 constant ERROR
3 constant ABORT

--- Error Handling Methods ---

: errlit ( ... k$ -- t$ )                             ( transforms literal key k$ with args ... to error text t$ )
  ;



=== Method invocation ====

: invokeMethod ( @inst mref -- )                      ( invoke methpd mref on instance @inst )
  swap class over 16 u>> FFFFH and  ( mref class dep# )
  over dup @DEPS + @ swap →DEPS + d@ ( mref class dep# @deps deps# ) 0 udo
    ( mref class dep# @deps ) 2dup cell+ d@ = if
      cell+ 4+ w@ ( mref class dep# vmbase ) nip rot FFFFH and + ( class vm# ) %cell 1+ u<< swap VMAT@ + @ + cell+ @
      unloop ( a ) execute exit  then
    ( mref class dep# @deps dep# )
    Dependency Size + loop  2drop drop
  Class name swap 10000H u%÷ "Method %d in dependency %d of class %s not found!"| MethodNotFoundException raise ; fallible
: invokeConstructor ( @class mref -- )                ( create instance of @class and invoke constructor mref )
  over Class size  unimplemented ;
: invokeDestructor ( @inst mref -- )                  ( invoke destructor mref on instance @inst and destroy @inst )
  unimplemented ;



=== Arithmetic Extensions ===

--- Limiters ---

--- advanced version for later
: !n1 ( n -- n )  dup nsize 1 > if  "N1expected" errlit ERROR raise  then ;  fallible  ( abort if n is not a signed byte )
: !u1 ( u -- u )  dup usize 1 > if  "U1expected" errlit ERROR raise  then ;  fallible  ( abort if u is not an unsigned byte )
: !n2 ( n -- n )  dup nsize 2 > if  "N2expected" errlit ERROR raise  then ;  fallible  ( abort if n is not a signed word )
: !u2 ( u -- u )  dup usize 2 > if  "U2expected" errlit ERROR raise  then ;  fallible  ( abort if u is not an unsigned word )
: !n4 ( n -- n )  dup nsize 4 > if  "N4expected" errlit ERROR raise  then ;  fallible  ( abort if n is not a signed double word )
: !u4 ( u -- u )  dup usize 4 > if  "U4expected" errlit ERROR raise  then ;  fallible  ( abort if u is not an unsigned double word )
: !n8 ( n -- n )  dup nsize 8 > if  "N8expected" errlit ERROR raise  then ;  fallible  ( abort if n is not a signed quad word )
: !u8 ( u -- u )  dup usize 8 > if  "U8expected" errlit ERROR raise  then ;  fallible  ( abort if u is not an unsigned quad word )
---
: !n1 ( n -- n -- ArithmeticException )               ( abort if n is not a signed byte )
  dup nsize 1 > if  "Expected N1, but got %d"| ERROR ArithmeticException new$ raise  then ;  fallible
: !u1 ( u -- u -- ArithmeticException )               ( abort if n is not a signed byte )
  dup usize 1 > if  "Expected U1, but got %D"| ERROR ArithmeticException new$ raise  then ;  fallible
: !n2 ( n -- n -- ArithmeticException )               ( abort if n is not a signed word )
  dup nsize 2 > if  "Expected N2, but got %d"| ERROR ArithmeticException new$ raise  then ;  fallible
: !u2 ( u -- u -- ArithmeticException )               ( abort if n is not a signed word )
  dup usize 2 > if  "Expected U2, but got %D"| ERROR ArithmeticException new$ raise  then ;  fallible
: !n4 ( n -- n -- ArithmeticException )               ( abort if n is not a signed double word )
  dup nsize 4 > if  "Expected N4, but got %d"| ERROR ArithmeticException new$ raise  then ;  fallible
: !u4 ( u -- u -- ArithmeticException )               ( abort if n is not a signed double word )
  dup usize 4 > if  "Expected U4, but got %D"| ERROR ArithmeticException new$ raise  then ;  fallible
: !n8 ( n -- n -- ArithmeticException )               ( abort if n is not a signed quadword )
  dup nsize 8 > if  "Expected N8, but got %d"| ERROR ArithmeticException new$ raise  then ;  fallible
: !u8 ( u -- u -- ArithmeticException )               ( abort if n is not a signed quadword )
  dup usize 8 > if  "Expected U8, but got %D"| ERROR ArithmeticException new$ raise  then ;  fallible

=== Class Check ===

: !type ( obj @c -- obj -- TypeCastException )       ( assert that obj points at an instance of class @c )
  over q@ obj>cid over cls>cid type-assignable unless
    over >type type$ swap type$ "Expected an object of %s, but got %s"| ERROR TypecastException new$ raise  then  drop ;  fallible



=== Module Initialization ===

init: ( @initstr -- @initstr )  ' !class TYPE_CHECKER ! ;

vocabulary;