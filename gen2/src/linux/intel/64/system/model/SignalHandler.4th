( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Signal Handler model for FORCE-linux 4.19.0-5-amd64 ******

class: SignalHandler
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  Cell val Function                                   ( Address of the signal handler function )
  SignalSet val Mask                                  ( Signals to mask while the handler function is running )
  SignalBehavior val Behavior                         ( Signal behavior flags )



  === Methods ===

public:
   : >sighandler ( -- SigHandler )                    ( transfor to structure as used by Linux )
     my Function  my Mask SignalSet >bits  my Behavior SignalBehavior >bits  SigHandler new ;

class;
