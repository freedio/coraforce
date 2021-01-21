( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Access Rights model for FORCE-linux 4.19.0-5-amd64 ******

enum: AccessRights
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol Execute              ( execute access granted: PROT_EXEC )
  symbol Write                ( write access granted: PROT_WRITE )
  symbol Read                 ( read access granted: PROT_READ )



  === Methods ===



enumset;
