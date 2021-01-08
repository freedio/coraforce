( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux OpenFile Module for FORCE-linux 4.19.0-5-amd64 ******

class: OpenFile  extends IO
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  requires force/intel/64/core/Buffer
  uses linux/intel/64/system/SystemMacro



  === Fields ===




  === Methods ===

  : stat ( -- FileStatus t | err f )                  ( Status of the file )
    FileStatus new dup my Handle SYS-FSTAT, RESULT0, dup unlessever  rot drop  then ;


class;
