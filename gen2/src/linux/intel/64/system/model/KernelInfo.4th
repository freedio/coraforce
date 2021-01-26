( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Kernel Info model for FORCE-linux 4.19.0-5-amd64 ******

class: KernelInfo
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  ZString65 val SysName            ( Operating system name [e.g., "Linux"]: utsname.sysname )
  ZString65 val NodeName           ( Name within "some implementation-defined network": utsname.nodename )
  ZString65 val Release            ( Operating system release [e.g., "2.6.28"]: utsname.release )
  ZString65 val Version            ( Operating system version: utsname.version )
  ZString65 val Machine            ( Hardware identifier: utsname.machine )
  ZString65 val DomainName         ( NIS or YP domain name: utsname.domainname )



  === Methods ===

public:
  construct: new ( -- )  newZString65 my SysName!  newZString65 my NodeName!  newZString65 my Release!
    newZString65 my Version!  newZString65 my Machine!  newZString65 my DomainName! ;

class;
