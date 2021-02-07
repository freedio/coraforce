( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The BitSet Module for FORCE-linux 4.19.0-5-amd64 ******


package force/intel/64/core
import Force

class: BitSet

  === Fields ===

  cell val Address           ( Address of the buffer )
  cell val Length            ( Buffer length, in bytes )
  cell val #Bits             ( Buffer size, in bits )



  === Methods ===

see !

construct: new ( u -- )                               ( initialize this BitSet for u contiguous bits, all bits clear )
  dup my #Bits !  7 + 3 u>> dup my Length ! allocate  my Address !  my Address@ my Length@ 0 cfill ;
destruct:  my Address@ free ;

class;
