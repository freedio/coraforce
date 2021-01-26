( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Symbolic Link Module for FORCE-linux 4.19.0-5-amd64 ******

class: Symlink  extends linux/intel/64/system/File
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/System
  uses linux/intel/64/system/SystemMacro



  === Fields ===



  === Methods ===

  : Status@ ( -- FileStatus )                         ( Status of the symbolic link )
    newFileStatus dup my Name SYS-LSTAT, SystemError0 KO ifever  drop  then ;  fallible


class;
