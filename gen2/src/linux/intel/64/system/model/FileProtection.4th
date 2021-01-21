( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Protection model for FORCE-linux 4.19.0-5-amd64 ******

enumset: FileProtection extends Protection
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol Sticky               ( sticky bit )
  symbol SetGID               ( set group id )
  symbol SetUID               ( set user id )



  === Methods ===



enumset;
