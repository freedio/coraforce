( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux FileStatus model for FORCE-linux 4.19.0-5-amd64 ******

class: FileStatus
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Interface ===

  U8 val Device                                       ( ID of device containing file )
  U8 val Inode                                        ( Inode number )
  U4 val Mode                                         ( File type and mode )
  U8 val #Links                                       ( Number of hard links )
  U4 val UID                                          ( User ID of owner )
  U4 val GID                                          ( Group ID of owner )
  U8 val DeviceID                                     ( Device ID, if special file )
  I8 val Size                                         ( Total size, in bytes )
  I8 val BlockSize                                    ( Block size for filesystem I/O )
  I8 val #Blocks                                      ( Number of 512B blocks allocated )
  FileTime val LastAccessed                           ( Time of last access )
  FileTime val LastModified                           ( Time of last modification )
  FileTime val LastChanged                            ( Time of last status change )



  === Implementation ===



class;
