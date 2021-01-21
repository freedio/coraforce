( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Protection model for FORCE-linux 4.19.0-5-amd64 ******

enumset: Protection
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol OtherExecute         ( others have execute permission: S_IXOTH )
  symbol OtherWrite           ( others have write permission: S_IWOTH )
  symbol OtherRead            ( others have read permission: S_IROTH )
  symbol GroupExecute         ( group has execute permission: S_IXGRP )
  symbol GroupWrite           ( group has write permission: S_IWGRP )
  symbol GroupRead            ( group has read permission: S_IRGRP )
  symbol OwnerExecute         ( owner has execute permission: S_IXUSR )
  symbol OwnerWrite           ( owner has write permission: S_IWUSR )
  symbol OwnerRead            ( owner has read permission: S_IRUSR )



  === Methods ===



enumset;
