( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Input/Output module for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64
import /force/intel/64/core/ForthBase
import system/IO

vocabulary: Inout
  require IO

10 =variable CR                                       ( single newline character )

: cr ( -- )  CR 1 stdout write drop ;                 ( send a newline to standard output )
: ecr ( -- )  CR 1 stderr write drop ;                ( send a newline to standard error )

vocabulary;
