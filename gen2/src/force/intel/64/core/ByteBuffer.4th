( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The ByteBuffer Module for FORCE-linux 4.19.0-5-amd64 ******

class: ByteBuffer
  package force/intel/64/core

  cell val Address                                    ( Address of the buffer )
  cell val Capacity                                   ( Buffer capacity )
  cell var InPtr                                      ( Offset of next byte to write )
  cell var OutPtr                                     ( Offset of next byte to read )

  : new ( # -- Buffer )                               ( create new buffer with capacity # )
    ByteBuffer alloc  2dup Capacity!  swap allocate over Address!  0 over InPtr!  0 over OutPtr! ;  static

  : consume ( # [this] -- #' )                        ( try to consume # bytes; report consumed bytes #' )
    my InPtr@  my OutPtr@  −  0 max dup my OutPtr +! ;
  : provide ( # [this] -- #' )                        ( try to provide # bytes; report previded bytes #' )
    my Capacity@ my InPtr@  −  0 max dup my InPtr +! ;
  : takeFrom ( a # [this] -- #' )                     ( move # bytes to buffer at address a; report #transferred bytes #' )
    my InPtr@ my OutPtr@ - 0 max min tuck  my Address@ my OutPtr@ + swap cmove  dup my OutPtr +! ;
  : appendTo ( a # [this] -- #' )                     ( try to append the specified buffer a#; report appended bytes #' )
    my Capacity@  my InPtr@  −  0 max min tuck  my Address@ my InPtr@ + swap cmove  dup my InPtr +! ;
  : compact ( [this] -- )                             ( compacts the buffer by moving the content down to the beginning )
    ... ;

class;
