( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The BitSet Module for FORCE-linux 4.19.0-5-amd64 ******

class: BitSet
  package force/intel/64/core
  requires force/intel/64/core/RichForce



  === Fields ===

  cell val Address                                    ( Address of the buffer )
  cell val Length                                     ( Buffer length, in bytes )
  cell val Size                                       ( Buffer size, in bits )



  === Methods ===

construct: new ( u -- )                                   ( initialize this BitSet for u contiguous bits, all bits clear )
  dup my Size!  7 + 3 u>> dup my Length! allocate  my Address!  my Address@ my Length@ 0 cfill ;
destroy:  my Address@ free ;

class;
