( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux ZString65 model for FORCE-linux 4.19.0-5-amd64 ******

class: ZString65
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

private:
  create Body  65 allot                               ( Buffer for 64 chars and one zero-delimiter )



  === Methods ===

public:
  construct: fromString ( $ -- )  my Body 65 0 cfill  count 64 max  my Body swap cmove ;
  construct: new ( -- )  my Body 65 0 cfill ;

structure;
