( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Selector Module for FORCE-linux 4.19.0-5-amd64 ******

class: Selector
  package linux/intel/64/system
  requires force/intel/64/core/RichForce
  uses linux/intel/64/system/SystemMacro



  === Fields ===

  IO List val CheckForInput                           ( Selectors to check for input )
  IO List val CheckForOutput                          ( Selectors to check for output )
  IO List val CheckForExcept                          ( Selectors to check for exceptions )
  U4 val MaxSelector                                  ( Highest IO number in all sets + 1 )
  BitSet var input                                    ( Selectors ready for input )
  BitSet var output                                   ( Selectors ready for output )
  BitSet var except                                   ( Selectors with an exception )



  === Methods ===

private:
  : >bits ( IO_List -- BitSet )                       ( transform IO List into a bit set )
    1024 newBitSet >x  List iterate begin  next? while  next bit x@ setBitSet  repeat  x> ;
  : bits+! ( IO_List BitSet -- )                       ( adds IOs designated by BitSet to IO List )
    BitSet iterate begin  next? while  next IO get over List+!  repeat  2drop ;
  : maxSelector ( IO_List -- u )                      ( number of highest selector in IO List )
    0 swap IO List iterate begin  next? while  next IOHandle@ rot max swap  repeat  1 + ;

public:
  : waitFor ( timeout -- rdyin rdout excpt )          ( wait for action triggers )
    >x my CheckForInput >bits dup my input!  my CheckForOutput >bits dup my output!  my CheckForExcept dup my except!
    x> MicroTime>timeval  my MaxSelector@ SYS-SELECT,
    OK if  IO List new  my input bits+!  my output bits+!  my except bits+!  then ;  fallible

construct: new ( IO_List:inp IO_List:out IO_List:exc -- )  dup my CheckForExcept!  dup my CheckForOutput!  dup my CheckForInput!
  maxSelector swap  maxSelector max  maxSelector max  my MaxSelector! ;

class;
