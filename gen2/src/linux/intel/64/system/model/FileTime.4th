( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux FileTime model for FORCE-linux 4.19.0-5-amd64 ******

structure: FileTime
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Interface ===

  U8 val Seconds                                      ( The seconds-since-the-epoch part )
  U8 val Nanoseconds                                  ( The nano-seconds with the second, 0..999,999,999 )



  === Implementation ===



structure;
