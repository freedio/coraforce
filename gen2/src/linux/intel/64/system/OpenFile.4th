( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux OpenFile Module for FORCE-linux 4.19.0-5-amd64 ******

class: OpenFile  extends IO
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/System
  uses linux/intel/64/system/SystemMacro



  === Fields ===



  === Methods ===

private:
  : type+mode>bits ( MemMapType MemMapMode -- u )     ( composes Linux "fl" from type and mode )
    MemMapMode >bits swap MemMapType >value + ;

public:
  : stat ( -- FileStatus t | LinuxError f )           ( Status of the file )
    FileStatus new dup my Handle SYS-FSTAT, SystemResult1 dup unlessever  rot drop  then ;
  : --> ( u -- u' t | LinuxError f )                  ( advance cursor by u and report new position u' )
    SeekMode FromCurrent my Handle SYS-SEEK, SystemResult1 ;
  : |--> ( u -- u' t | LinuxError f )                 ( set cursor to u and report new position u' )
    SeekMode FromStart my Handle SYS-SEEK, SystemResult1 ;
  : -|-> ( u -- u' t | LinuxError f )                 ( set cursor u beyond EOF and report new position u' )
    SeekMode FromEnd my Handle SYS-SEEK, SystemResult1 ;
  : ->D ( u -- u' t | LinuxError f )                  ( advance cursor to next data after abs pos u and report new position u' )
    SeekMode ToData my Handle SYS-SEEK, SystemResult1 ;
  : ->H ( u -- u' t | LinuxError f )                  ( advance cursor to next hole after abs pos u and report new position u' )
    SeekMode ToHole my Handle SYS-SEEK, SystemResult1 ;
  : map ( # u t m p -- MemoryArea t | LinuxError f )  ( Maps # bytes from offset u into memory area MemoryArea¹ )
    ( ¹ MemMapType t defines the type, MemMapMode the mode, and MemProtection p the memory protection )
    MemProtection >bits -rot type+mode>bits rot ( # pr fl u )  0 5 -roll ( 0 # pr fl u )  3 pick >x  SYS-MMAP, SystemResult1
    dup if  swap x@ -1 MappedMemoryArea new swap  then  xdrop ;
  : readAbsFrom ( a # u -- #' t | LinuxError f )      ( read # bytes from abs pos u to buffer a, report actually read → #' )
    my Handle SYS-PREAD, SystemResult1 ;
  : writeAbsTo ( a # u -- #' t | LinuxError f )       ( write # bytes to abs pos u from buffer a, report actually written → #' )
    my Handle SYS-PWRITE, SystemResult1 ;

class;
