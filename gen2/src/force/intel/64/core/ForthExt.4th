( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The FORTH extension vocabulary of FORCE-linux 4.19.0-5-amd64 ******

package force/intel/64/core
import ForthBase
import force/intel/64/macro/CoreMacro
import force/intel/64/core/ArithmeticException

vocabulary: ForthExt
  requires ForthBase
  requires ArithmeticException



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
: !n1 ( n -- n )                                      ( abort if n is not a signed byte )
  dup nsize 1 > if  "Expected N1, but got %d" ERROR ArithmeticException new raise  then ;  fallible
: !u1 ( u -- u )                                      ( abort if n is not a signed byte )
  dup usize 1 > if  "Expected U1, but got %D" ERROR ArithmeticException new raise  then ;  fallible
: !n2 ( n -- n )                                      ( abort if n is not a signed word )
  dup nsize 2 > if  "Expected N2, but got %d" ERROR ArithmeticException new raise  then ;  fallible
: !u2 ( u -- u )                                      ( abort if n is not a signed word )
  dup usize 2 > if  "Expected U2, but got %D" ERROR ArithmeticException new raise  then ;  fallible
: !n4 ( n -- n )                                      ( abort if n is not a signed double word )
  dup nsize 4 > if  "Expected N4, but got %d" ERROR ArithmeticException new raise  then ;  fallible
: !u4 ( u -- u )                                      ( abort if n is not a signed double word )
  dup usize 4 > if  "Expected U4, but got %D" ERROR ArithmeticException new raise  then ;  fallible
: !n8 ( n -- n )                                      ( abort if n is not a signed quadword )
  dup nsize 8 > if  "Expected N8, but got %d" ERROR ArithmeticException new raise  then ;  fallible
: !u8 ( u -- u )                                      ( abort if n is not a signed quadword )
  dup usize 8 > if  "Expected U8, but got %D" ERROR ArithmeticException new raise  then ;  fallible

vocabulary;