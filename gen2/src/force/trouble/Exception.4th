( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Exception interface for FORCE-linux 4.19.0-5-amd64 ******

package force/trouble
import force/intel/64/core/ForthBase

interface: Exception

  def Stacktrace@                                     ( return the stack trace where the exception originated )
  def eprint ( -- )                                   ( print the exception to stderr )

interface;
