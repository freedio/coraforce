( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Memory Protection model for FORCE-linux 4.19.0-5-amd64 ******

U1 enumset: MemProtection
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol Read                 ( read access granted: PROT_READ )
  symbol Write                ( write access granted: PROT_WRITE )
  symbol Execute              ( execute access granted: PROT_EXEC )
  symbol Atomic               ( page can be used for atomic operations )



  === Methods ===



enumset;
