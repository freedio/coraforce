( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Descriptor model for FORCE-linux 4.19.0-5-amd64 ******

structure: SharedMemoryDescriptor
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  IpcPermissions val Permissions            ( Ownership and permissions )
  U8 val SegmentSize                        ( Size of the segment )
  U8 val LastAttached                       ( Last attach time [ms since the epoch] )
  U8 val LastDetached                       ( Last detached time [ms since the epoch] )
  U8 val LastModified                       ( Created, or last modified by shmctl [ms since the epoch] )
  N4 val Creator                            ( PID of creator )
  N4 val Modifier                           ( PID of last shmat/shmdt )
  U8 val #Attachments                       ( Current number of attachments )



  === Methods ===


structure;
