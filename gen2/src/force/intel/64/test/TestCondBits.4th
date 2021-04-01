( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The scratch test vocabulary of FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/core

import ForthBase

vocabulary: TestCondBits

variable a

: test15 ( -- )  a @ 15 if  nop  then ;
: testequal ( -- )  15 a @ = if  nop  then = ;
: testequal5 ( -- )  5 =  a @ 5 = if  nop  then ;
: testbit6 ( -- )  12 6 bit? a @ 6 bit? if  nop  then ;
: testsetbit12 ( -- )  a @ 12 bit?+ a @ 12 bit?+ if  nop  then ;
: testbit ( -- )  a @ dup bit? a @ bit? if  nop  then ;
: testclearbit ( -- )  bit?− a @ bit?− if  nop  then ;
: flipbit ( -- )  a @ dup bit× if  nop  then ;

vocabulary;

!voc TestCondBits
voc: TestCondBits

!def test15
!def testequal
!def testequal5
!def testbit6
!def testsetbit12
!def testbit
!def testclearbit
!def flipbit

!code test15
  8F 45 00 48 83 C5 08 50 48 B8 20 CB 7D DA 66 55 00 00 48 8B 00 50 B8 0F 00 00 00 48 85 C0 58 0F 84 01 00 00 00 90
  48 83 ED 08 FF 75 00 C3 ;
!code testequal
  8F 45 00 48 83 C5 08 50 48 B8 20 CB 7D DA 66 55 00 00 48 8B 00 50 B8 0F 00 00 00 48 85 C0 58 0F 84 01 00 00 00 90
  48 83 ED 08 FF 75 00 C3 ;
!code testequal5
  8F 45 00 48 83 C5 08 50 48 B8 20 CB 7D DA 66 55 00 00 48 8B 00 50 B8 0F 00 00 00 48 85 C0 58 0F 84 01 00 00 00 90
  48 83 ED 08 FF 75 00 C3 ;
!code testbit6
   8F 45 00 48 83 C5 08 50 B8 0C 00 00 00 48 0F BA E0 06 48 19 C0 50 48 B8 20 2B F4 DB 17 56 00 00 48 8B 00 48 0F BA
   E0 06 58 0F 83 01 00 00 00 90 48 83 ED 08 FF 75 00 C3
!code testsetbit12
   8F 45 00 48 83 C5 08 50 48 B8 20 2B 00 17 9D 55 00 00 48 8B 00 48 0F BA E8 0C 50 48 19 C0 50 48 B8 20 2B 00 17 9D 55 00 00
   48 8B 00 48 0F BA E8 0C 0F 83 01 00 00 00 90 48 83 ED 08 FF 75 00 C3 ;
!code testbit
  8F 45 00 48 83 C5 08 50 48 B8 20 2B F4 DB 17 56 00 00 48 8B 00 50 48 0F A3 04 24 5A 48 19 C0 50 48 B8 20 2B F4 DB 17 56 00 00
  48 8B 00 48 0F A3 04 24 5A 58 0F 83 01 00 00 00 90 48 83 ED 08 FF 75 00 C3 ;
!code testclearbit
  8F 45 00 48 83 C5 08 48 0F B3 04 24 48 19 C0 50 48 B8 20 2B F4 DB 17 56 00 00 48 8B 00 48 0F B3 04 24 58 0F 83 01 00 00 00
  90 48 83 ED 08 FF 75 00 C3 ;
!code flipbit
  8F 45 00 48 83 C5 08 50 48 B8 20 2B F4 DB 17 56 00 00 48 8B 00 50 48 0F BB 04 24 58 48 85 C0 58 0F 84 01 00 00 00 90
  48 83 ED 08 FF 75 00 C3 ;

!isonly test15  private static code-threaded joiner definition ;
!isonly testequal  private static code-threaded joiner definition ;
!isonly testequal5 private static code-threaded joiner definition ;
!isonly testbit6 private static code-threaded joiner definition ;
!isonly testsetbit12 private static code-threaded joiner definition ;
!isonly testbit private static code-threaded joiner definition ;
!isonly testclearbit private static code-threaded definition ;
!isonly flipbit private static code-threaded joiner definition ;
