( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The class and interface test vocabulary of FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/test

import /force/intel/64/core/ForthBase
import /force/intel/64/macro/CoreMacro
import model/TestClass

vocabulary: TestClassInterface
  requires TestClass
  requires ForthBase

: testClass ( -- )  TestClass new ;

vocabulary;

tests:

!voc TestClassInterface
voc: TestClassInterface
!def testClass

!isOnly testClass public static code-threaded joiner definition ;

!voc TestClass
voc: TestClass

!method X
!method y
!method new
( !method destroy )

!def X
!def y
!def new
!def destroy

tests;
