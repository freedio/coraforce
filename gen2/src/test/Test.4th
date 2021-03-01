( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** A test module for FORCE-linux 4.19.0-5-amd64 ******

package test
import /force/intel/64/core/ForthBase

vocabulary: Test

private: ( dummy definitions )
  : cr ;
  : $. ;

public:
  : testIfThen ( -- )  12 if  cr "Successful" $. then ;
  : test#?IfThen ( -- )  12 3 > if  cr "Successful" $. then ;
  : testIfElseThen ( -- )  12 if  cr "Successful" $. else cr "Failure" $. then ;
  : test#?IfElseThen ( -- )  12 3 > if  cr "Successful" $. else cr "Failure" $. then ;
  : testUnlessThen ( -- )  0 unless  cr "Successful" $. then ;
  : test#?UnlessThen ( -- )  1 3 > unless  cr "Successful" $. then ;
  : testIfeverThen ( -- )  12 ifever  cr "Successful" $. then ;
  : test#?IfeverThen ( -- )  12 3 > ifever  cr "Successful" $. then ;
  : testUnlesseverThen ( -- )  0 unlessever  cr "Successful" $. then ;
  : test#?UnlesseverThen ( -- )  1 3 > unlessever  cr "Successful" $. then ;
  : testBeginAgain ( -- )  begin cr "Looping" again ;
  : testBeginUntil ( -- )  begin cr "Looping" 23 until ;
  : testBegin#?Until ( -- )  begin cr "Looping" 0 < until ;
  : testBegin?Until ( -- )  begin cr "Looping" 0< until ;
  : testBeginWhileRepeat ( -- )  begin  12 while  "Looping" repeat ;
  : testBegin#?WhileRepeat ( -- )  begin  12 3 > while  "Looping" repeat ;
  : testBegin?WhileRepeat ( -- )  begin  12 0> while  "Looping" repeat ;

vocabulary;
