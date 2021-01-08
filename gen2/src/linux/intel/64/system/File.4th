( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Module for FORCE-linux 4.19.0-5-amd64 ******

class: File
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  ZString val Name                                    ( the file name, an zero-delimited absolute or relative Unix path )



  === Methods ===

  : open ( OpenMode AccessMode -- OpenFile t | err f )  ( opens the file with specified open and acces mode, returns open file )
    swap >unix swap >unit  my Name -rot SYS-OPEN, RESULT1, dup if  swap OpenFile new swap  then ;
  : stat ( -- FileStatus t | err f )                  ( Status of the file )
    FileStatus new dup my Name SYS-STAT, RESULT0, dup unlessever  rot drop  then ;


class;
