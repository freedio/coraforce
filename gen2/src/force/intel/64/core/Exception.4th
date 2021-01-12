( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Exception interface for FORCE-linux 4.19.0-5-amd64 ******

interface: Exception
  package force/intel/64/core
  requires force/intel/64/core/RichForce
  requires force/intel/64/core/StackTrace

  def Stacktrace@                                     ( return the stack trace where the exception originated )
  def eprint ( -- )                                   ( print the exception to stderr )

interface;
