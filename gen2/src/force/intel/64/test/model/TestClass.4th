( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Test Class Module for FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/test/model

import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro
( import /force/core/String )

class: TestClass
(  requires String )
  requires ForthBase



  === Fields ===

public:
  U1 val CharVal
  U2 val WordVal
  U4 var DwordVar
  U8 val QwordVal
  U16 var OwordVar
  N1 var ByteVar
  N2 var ShortVar
  N4 val IntVal
  N8 var LongVar
  N16 val HugeVal

  Real var RealVar

(  String val StringVal )



  === Methods ===

public:
  : X ( -- ) ;
  : y ( -- ) ;
  constructor: new ( -- )
    42 my CharVal c!  60000 my WordVal w!  -100,000,000 my DwordVar d!  1234567890ABCDEFH my QwordVal q!  -1 0 my OwordVar o!
    -13 my ByteVar b!  -4096 my ShortVar s!  -1 my IntVal i!  -1 my LongVar l!  -1 0 my HugeVal o!
    π my RealVar f!  ( "Hello, World!" my StringVal ! ) ;
  destructor: destroy ( -- ) ;

class;
