( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Module for FORCE-linux 4.19.0-5-amd64 ******

class: File
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  ZString val Name                                    ( the file name, an zero-delimited absolute or relative Unix path )



  === Methods ===

public:
  : open ( OpenMode AccessMode -- OpenFile t | LinuxError f )  ( open file with specified open+acces mode, return open file )
    swap >unix swap >unit  my Name -rot SYS-OPEN, SystemResult1 dup if  swap OpenFile new swap  then ;
  : Status ( -- FileStatus t | LinuxError f )         ( Status of the file )
    FileStatus new dup my Name SYS-STAT, SystemResult0 dup unlessever  rot drop  then ;
  : exists ( -- t | LinuxError f )                    ( Check if file exists )
    my Name 0 SYS-ACCESS, SystemResult0 ;
  : Access ( FileAccessRights -- t | LinuxError f )   ( Check if access of type FileAccessRights on file is granted )
    my Name swap SYS-ACCESS, SystemResult0 ;

construct: ( n$ -- File )  ZString ?new my Name! ;    ( initialize File with name n$ )

class;
