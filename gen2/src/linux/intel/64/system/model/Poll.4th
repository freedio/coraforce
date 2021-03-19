( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Poll model for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/model

import /linux/intel/64/system/IO

class: Poll



  === Interface ===

  IO val Observable                                   ( observed IO )
  PollEvents val Interests                            ( set of events we're interested in )
  PollEvents var Active                               ( set of active events on the observable )
  def >pollement ( -- Pollement )                     ( concert poll to a pollement )
  def new ( IO PollEvents -- )                        ( initialize object with observable IO and interests PollEvents )



  === Implementation ===

  : >pollement ( -- Pollement )  my Observable my Interests newPollement ;
  : new ( IO PollEvents -- )  my Interests !  my Observable ! ;



class;
