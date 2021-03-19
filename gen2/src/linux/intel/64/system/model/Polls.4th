( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Polls model for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/model

import Poll
import /forth/intel/64/core/ForthBase

class: Polls



  === Interface ===

  Poll List val Polls                                 ( the underlying list of polls )
  def >a# ( -- @p[] #p )                              ( convert the polls into an array of poll entries @p[] and its length #p )
  def new ( PollList -- )                             ( initialize object from a list of polls )



  === Implementation ===

  : >a# ( -- @p[] #p )                                ( convert the polls into an array of poll entries @p[] and its length #p )
    Pollement my Polls Length array >x  my Polls iterate begin  next? while  next x@ add  repeat  x> count ;
  : new ( PollList -- )  my Polls ! ;

class;
