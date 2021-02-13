( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Trouble Severity model for FORCE-linux 4.19.0-5-amd64 ******

package force/trouble/model
import /force/intel/64/core/ForthBase

enum: Severity



  === Fields ===

  symbol INFORMATION          ( Purely informative )
  symbol ATTENTION            ( More than informative, so needs attention, but is not yet a problem )
  symbol WARNING              ( Warning: the system could run into trouble; should be fixed in the long run )
  symbol ERROR                ( Something severe, but we can still continue )
  symbol ABORT                ( System is in an unrecoverable state )

enum;
