( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Polls model for FORCE-linux 4.19.0-5-amd64 ******

class: Polls
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  Poll List val Polls                                 ( the underlying list of polls )



  === Methods ===

  : >a# ( -- @p[] #p )                                ( convert the polls into an array of poll entries @p[] and its length #p )
    Pollement my Polls Length array >x
    my Polls ’ >pollement map

class;
