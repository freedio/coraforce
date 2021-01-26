( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Poll model for FORCE-linux 4.19.0-5-amd64 ******

class: Poll
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  IO val Observable                                   ( observed IO )
  PollEvents val Interests                            ( set of events we're interested in )
  PollEvents var Active                               ( set of active events on the observable )



  === Methods ===

  : >pollement ( -- Pollement )  my Observable my Interests newPollement ;



class;
