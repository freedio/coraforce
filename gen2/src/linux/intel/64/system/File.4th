( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux File Module for FORCE-linux 4.19.0-5-amd64 ******

class: File extends IO
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  ZString val Name                                    ( the file name, an zero-delimited absolute or relative Unix path )



  === Methods ===

public:
  : open ( OpenMode AccessMode -- OpenFile )          ( open file with specified open+acces mode, return open file )
    swap >unix swap >unit  my Name@ -rot SYS-OPEN, SystemResult1  OK if  OpenFile new  then ;  fallible
  : Status@ ( -- FileStatus )                         ( Status of the file )
    FileStatus new dup my Name@ SYS-STAT, SystemResult0 reallyKO ifever  drop  then ;  fallible
  : exists ( -- ? )                                   ( check if file exists )
    my Name@ 0 SYS-ACCESS, ?Result0 ;
  : !exists ( -- )                                    ( make sure the file exists )
    my Name@ 0 SYS-ACCESS, SystemResult0 ;  fallible
  : Access ( FileAccessRights -- ? )                  ( check if access of type FileAccessRights is granted on file )
    my Name@ swap SYS-ACCESS, ?Result0 ;              ( note that there is no detail about an error, if there was one )
  : !access ( FileAccessRights -- )                   ( make sure access of type FileAccessRights is granted on file )
    my Name@ swap SYS-ACCESS, SystemResult0 ;  fallible
  : execute ( @args @env -- )                         ( exec the file as a program, passing @args and @env; does not return if OK )
    my Name@ -rot SYS-EXECVE, SystemResult0

construct: new ( n$ -- File )  ZString ?new my Name! ; ( initialize File with name n$ )

class;
