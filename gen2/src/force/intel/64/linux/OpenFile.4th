( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux OpenFile Module for FORCE-linux 4.19.0-5-amd64 ******

class: OpenFile  package force/intel/64/linux  extends File
  requires force/intel/64/core/RichForce
  requires force/intel/64/core/Buffer
  uses force/intel/64/linux/SystemMacro



  === Fields ===

  U4 var Descriptor



  === Methods ===

  : readTo ( a # -- #' t | errno f )                  ( read # bytes to address a & report actual bytes read #' )
    my Descriptor  SYS-READ,  dup abs swap 0≥ ;
  : writeFrom ( a # -- #' t | errno f )               ( write # bytes from address a & report actual bytes written #' )
    my Descriptor  SYS-WRITE,  dup abs swap 0≥ ;
  : read ( # -- @bfr t | errno f )                    ( read # bytes into buffer @bfr )
    Buffer new  dup AddrCap@  my Descriptor  SYS-READ, 0<?ifever  swap reclaim ± false  else  over Size! true  then ;
  : write ( @bfr --


class;
