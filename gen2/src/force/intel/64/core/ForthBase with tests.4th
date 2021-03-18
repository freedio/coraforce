( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The FORTH base vocabulary of FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/core
import force/intel/64/macro/CoreMacro

vocabulary: ForthBase

--- On stack comments:  we use
    ? ("truebool")  for true boolean (0 or -1)
    -? ("boolean")  for boolean ( 0 or not-0)
    t ("true")      for true (the value -1)
    f ("false")     for false (the value 0)
    -f ("notfalse") for not-false (any value except 0)
    c ("char")      for unsigned byte
    b ("byte")      for   signed byte
    w ("word")      for unsigned word (2 bytes)
    s ("short")     for   signed word (2 bytes)
    d ("dword")     for unsigned double word (4 bytes)
    i ("integer")   for   signed double word (4 bytes)
    q ("qword")     for unsigned quad-word (8 bytes)
    l ("long")      for   signed quad-word (8 bytes)
    o ("oword")     for unsigned oct-word (16 bytes)
    h ("huge")      for   signed oct-word (16 bytes)
    x ("cell")      for cell-size value (64 bit system: 8 bytes, 32 bit systems: 4 bytes)
    2x ("cellpair") for cell pair or double-cell (higher cell under lower cell)
    a ("address")   for any address, cell size by nature
    $ ("string")    for counted strings (the count being a witch)
    r ("real")      for floating point number (10 bytes on x87, otherwise usually 8 bytes)
---

--- On I64 registers: we use
    SS:RSP    for PSP (parameter stack pointer)
    SS:RBP    for RSP (return stack pointer)
    RAX       for TOS (top of stack)
    DS:RBX    for COA (current object address)
    DS:RSI    for PAA (parameter area address)
    DS:RDI    for ESP (exception stack pointer)
---



=== Constants ===

: cell ( -- cell#:C )  CELL, ;                        ( Cell size )
: %cell ( -- %cell:C )  cell 8 u* ;                   ( Cell Shift )
: cell+ ( x -- x+cell# )  CELLPLUS, ;                 ( add cell size to x )
: cells ( n -- n*cell# )  CELLTIMES, ;                ( multiply n with cell size )
: cellu/ ( u -- u/cell# )  CELLUBY, ;                 ( divide u through cell size )
0 constant false                                      ( the value considered 'false' )
-1 constant true                                      ( the value considered 'real true' )
: bl ( -- ␣ )  BLANK, ;  alias ␣                      ( the space or blank character )

--- Initialization Vector Structure ---

0000  dup constant @PSP  private                      ( Address of the parameter stack )
cell+ dup constant #PSP  private                      ( Size of the parameter stack in cells )
cell+ dup constant @RSP  private                      ( Address of the return stack )
cell+ dup constant #RSP  private                      ( Size of the return stack in cells )
cell+ dup constant @XSP  private                      ( Address of the extra stack )
cell+ dup constant #XSP  private                      ( Size of the extra stack in cells )
cell+ dup constant @@SourceFile  private              ( Address of the variable containing the source file name )
cell+ dup constant @#SourceLine  private              ( Address of the variable containing the source line number )
cell+ dup constant @#SourceColumn  private            ( Address of the variable containing the source column number )
cell+ dup constant ExHandler#  private                ( Address of the exception handler )
cell+ dup constant InitVector#  private               ( Size of the initialization vector )
drop



=== Stack Operations ===

------
Assumption is that the parameter and return stacks grows downwards, all others upwards.
Imposed by the architecture, parameter and return stack reside in the same segment and converge on each other.
The term "stack" without further specification refers to the parameter stack.
------

--- Static Stack State ---

variable PSP0      ( Initial parameter stack pointer )
variable PSS       ( Parameter stack size in cells )
variable RSP0      ( Initial return stack pointer )
variable RSS       ( Return stack size in cells )
variable OSP0      ( Initial object stack pointer )
variable OSS       ( Object stack size in cells )
variable XSP0      ( Initial extra stack pointer )
variable XSS       ( Extra stack size in cells )
variable YSP0      ( Initial Y-stack pointer )
variable YSS       ( Y-stack size in cells )
variable ZSP0      ( Initial X-stack pointer )
variable ZSS       ( Z-stack size in cells )

--- Stack Operations ---

: sp0 ( -- sp )  PSP0 QFETCH, ;                       ( Initial parameter stack pointer )
: sp@ ( -- sp )  GETSP, ;                             ( Current parameter stack pointer )
: sp! ( sp -- )  SETSP, ;                             ( set parameter stack pointer )
: sp0! ( -- )  sp0 sp! ;                              ( reset parameter stack to initial )
: sp# ( -- u )  PSS QFETCH, ;                         ( Total parameter stack size in cells )
: sp## ( -- u )  PSS QFETCH, cells ;                  ( Total parameter stack size in bytes )
: depth ( -- u )  sp0 sp@ MINUS, cellu/ ;             ( Number of cells occupied on parameter stack )

: dup ( x -- x x )  DUP, ;                            ( duplicate top of stack )
: trip ( x -- x x x )  TRIP, ;                        ( triplicate top of stack )
: drop ( x -- )  DROP, ;                              ( drop top of stack )
: zap ( x -- 0 )  ZAP, ;                              ( replace top of stack with 0; cheaper than "drop 0" or "0 and" )
: swap ( x2 x1 -- x1 x2 )  SWAP, ;                    ( swap top and second of stack )
: over ( x2 x1 -- x2 x1 x2 )  OVER, ;                 ( copy second over top of stack )
: tuck ( x2 x1 -- x1 x2 x1 )  TUCK, ;                 ( tuck top of stack under second )
: nip ( x2 x1 -- x1 )  NIP, ;                         ( drop second of stack )
: nip2 ( x3 x2 x1 -- x1 )  NIP2, ;                    ( drop second and third of stack )
: smash ( x2 x1 -- x2 x2 )  SMASH, ;                  ( replace top of stack with second )
: rot ( x3 x2 x1 -- x2 x1 x3 )  ROT, ;                ( rotate top stack triple )
: -rot ( x3 x2 x1 -- x1 x3 x2 )  ROTR, ;              ( reverse rotate top stack triple )
: slide ( x3 x2 x1 -- x2 x3 x1 )  SLIDE, ;            ( exchange 2nd and 3rd of stack )
: rev ( x3 x2 x1 -- x1 x2 x3 )  REV, ;                ( revert stack triple = exchange top and 3rd of stack )

: 2dup ( y x -- y x y x )  2DUP, ;                    ( duplicate top of stack pair )
: 2drop ( y x -- )  2DROP, ;                          ( drop top of stack pair )
: 2nip ( y2 x2 y1 x1 -- y1 x1 )  2NIP, ;              ( drop 2 cells above top )
: 2swap ( y2 x2 y1 x1 -- y1 x1 y2 x2 )  2SWAP, ;      ( swap top and second of stack pair )
: 2over ( y2 x2 y1 x1 -- y2 x2 y1 x1 y2 x2 )  2OVER, ; ( copy second over top of stack pair )
: pick ( ... u -- ... xu )  PICK, ;                   ( pick the uth stack element below u )
: roll ( xn xm ... xu u -- xm ... xu xn )  ROLL, ;    ( rotate stack u-tuple down )
: -roll ( xn xm ... xu u -- xu xn xm ... )  ROLLR, ;  ( rotate stack u-tuple up )
: ?dup ( x -- x x | 0 )  ?DUP, ;                      ( duplicate top of stack unless it's 0 )

--- Return Stack Operations ---

: rp0 ( -- rp )  RSP0 QFETCH, ;                       ( Initial return stack pointer )
: rp@ ( -- rp )  GETRP, ;                             ( Current return stack pointer )
: rp! ( rp -- )  SETRP, ;                             ( set return stack pointer )
: rp!@ ( rp -- rp )  SETRP,  GETRP, ;        
: rdepth ( -- n )  rp0 rp@ RMINUS, ABS, cellu/ ;      ( Number of cells occupied on return stack )
: r> ( -- x |R: x -- )  FROMR, ;                      ( move top of return stack to parameter stack )
: >r ( x -- |R: -- x )  TOR, ;                        ( move top of parameter stack to return stack )
: r@ ( -- x |R: x -- x )  RFETCH, ;                   ( copy top of return stack to parameter stack )
: r! ( x -- x |R: -- x )  RCOPY, ;                    ( copy top of parameter stack on return stack )
: rdrop ( -- |R: x -- )  RDROP, ;                     ( drop top of return stack )
: rdup ( -- |R: x -- x x )  RDUP, ;                   ( duplicate top of return stack )
: i ( -- index |R: limit index -- limit index )  LOOPINDEX, ;         ( Index of innermost loop )
: limit ( -- limit |R: limit index -- limit index )  LOOPLIMIT, ;     ( Limit of innermost loop )
: j ( -- index1 |R: limit1 index1 limit2 index2 -- limit1 index1 limit2 index2 )  LOOPINDEX2, ;       ( Index of outer loop )
: ljmit ( -- limit1 |R: limit1 index1 limit2 index2 -- limit1 index1 limit2 index2 )  LOOPLIMIT2, ;   ( Limit of outer loop )
: unloop ( -- )  2RDROP, ;                            ( prepare for EXIT from within one DO...LOOP structure )



=== Memory Fetch and Store Operations ===

( Note that for store operations, always two variants are provided: one with value over address [as seen from TOS] and one with
  value under address.  The classic FORTH variant is "over", but the variant which often makes more sense is "under",
  particularly with post-increment, pre-decrement et al.
  With numeric clauses, the sense is automatically determined, so  SIZE 4 !  or  SIZE 4!  will both be translated to SIZE 4#! )

--- Store ---

: c! ( c a -- )  CSTORE, ;                            ( store unsigned byte c at address a )
alias b! ( b a -- )                                   ( store signed byte b at address a )
: w! ( w a -- )  WSTORE, ;                            ( store unsigned word w at address a )
alias s! ( s a -- )                                   ( store signed word s at address a )
: d! ( d a -- )  DSTORE, ;                            ( store unsigned double-word d at address a )
alias i! ( i a -- )                                   ( store signed double-word at address a )
: q! ( q a -- )  QSTORE, ;                            ( store unsigned quad-word q at address a )     alias !
alias l! ( l a -- )                                   ( store signed quad-word q at address  a )
: o! ( o a -- )  OSTORE, ;                            ( store unsigned oct-word o at address a )
alias h! ( h a -- )                                   ( store signed oct-word at address a )

: on ( a -- )  -1! ;                                  ( set cell at address a to true )
: off ( a -- )  0! ;                                  ( set cell at address a to false )

--- Store with post-increment under ---

: !c++ ( a c -- a+1 )  STORECINC, ;                   ( store unsigned byte c at address a and increment the address )
alias !b++ ( a b -- a+1 )                             ( store signed byte b at address a and increment the address )
: !w++ ( a w -- a+2 )  STOREWINC, ;                   ( store unsigned word w at address a and increment the address )
alias !s++ ( a s -- a+2 )                             ( store signed word s at address a and increment the address )
: !d++ ( a d -- a+4 )  STOREDINC, ;                   ( store unsigned double-word d at address a and increment the address )
alias !i++ ( a i -- a+4 )                             ( store signed double-word i at address a and increment the address )
: !q++ ( a q -- a+8 )  STOREQINC, ;                   ( store unsigned quad-word q at address a and increment the address )
alias !l++ ( a l -- a+8 )                             ( store signed quad-word l at address a and increment the address )
: !o++ ( a o -- a+16 )  STOREOINC, ;                  ( store unsigned oct-word o at address a and increment the address )
alias h!++ ( a h -- a+16 )                            ( store signed oct-word h at address a and increment the address )

: #! ( n a # -- )  #NSTORE, ;                         ( store # least significant bytes of signed n at address a )
: u#! ( u a # -- )  #USTORE, ;                        ( store # least significant bytes of unsigned u at address a )


--- Store with post-increment over ---

: c!++ ( c a -- a+1 )  CSTOREINC, ;                   ( store unsigned byte c at address a and increment the address )
alias b!++ ( b a -- a+1 )                             ( store signed byte b at address a and increment the address )
: w!++ ( w a -- a+2 )  WSTOREINC, ;                   ( store unsigned word w at address a and increment the address )
alias s!++ ( s a -- a+2 )                             ( store signed word s at address a and increment the address )
: d!++ ( d a -- a+4 )  DSTOREINC, ;                   ( store unsigned double-word d at address a and increment the address )
alias i!++ ( i a -- a+4 )                             ( store signed double-word i at address a and increment the address )
: q!++ ( q a -- a+8 )  QSTOREINC, ;                   ( store unsigned quad-word q at address a and increment the address )
alias l!++ ( l a -- a+8 )                             ( store signed quad-word l at address a and increment the address )
: o!++ ( o a -- a+16 )  OSTOREINC, ;                  ( store unsigned oct-word o at address a and increment the address )
alias h!++ ( h a -- a+16 )                            ( store signed oct-word h at address a and increment the address )

--- Store with pre-decrement under ---

: --!c ( a c -- a−1 )  DECSTOREC, ;                   ( decrement the address and store unsigned byte c at address a−1 )
alias --!b ( a b -- a−1 )                             ( decrement the address and store signed byte b at address a−1 )
alias −−!c  alias −−!b                                ( aliases with real minus signs )
: --!w ( a w -- a−2 )  DECSTOREW, ;                   ( decrement the address and store unsigned word w at address a−2 )
alias --!s ( a s -- a−2 )                             ( decrement the address and store signed word s at address a−2 )
alias −−!w  alias −−!s                                ( aliases with real minus signs )
: --!d ( a d -- a−4 )  DECSTORED, ;                   ( decrement the address and store unsigned double-word d at address a−4 )
alias --!i ( a i -- a−4 )                             ( decrement the address and store signed double-word i at address a−4 )
alias −−!d  alias −−!i                                ( aliases with real minus signs )
: --!q ( a q -- a−8 )  DECSTOREQ, ;                   ( decrement the address and store unsigned quad-word q at address a−8 )
alias --!l ( a l -- a−8 )                             ( decrement the address and store signed quad-word l at address a−8 )
alias −−!q  alias −−!l  alias −−!                     ( aliases with real minus signs )
: --!o ( a o -- a−16 )  DECSTOREO, ;                  ( decrement the address and store unsigned oct-word o at address a−16 )
alias --!h ( a h -- a−16 )                            ( decrement the address and store signed oct-word h at address a−16 )
alias −−!o  alias −−!v                                ( aliases with real minus signs )

--- Store with pre-decrement over ---

: --c! ( c a -- a−1 )  DECCSTORE, ;                   ( decrement the address and store unsigned byte c at address a−1 )
alias --b! ( b a -- a−1 )                             ( decrement the address and store signed byte b at address a−1 )
alias −−c!  alias −−b!                                ( aliases with real minus signs )
: --w! ( w a -- a−2 )  DECWSTORE, ;                   ( decrement the address and store unsigned word w at address a−2 )
alias --s! ( s a -- a−2 )                             ( decrement the address and store signed word s at address a−2 )
alias −−w!  alias −−s!                                ( aliases with real minus signs )
: --d! ( d a -- a−4 )  DECDSTORE, ;                   ( decrement the address and store unsigned double-word d at address a−4 )
alias --i! ( i a -- a−4 )                             ( decrement the address and store signed double-word i at address a−4 )
alias −−d!  alias −−i!                                ( aliases with real minus signs )
: --q! ( q a -- a−8 )  DECQSTORE, ;                   ( decrement the address and store unsigned quad-word q at address a−8 )
alias --l! ( l a -- a−8 )                             ( decrement the address and store signed quad-word l at address a−8 )
alias −−q!  alias −−l!  alias −−!                     ( aliases with real minus signs )
: --o! ( o a -- a−16 )  DECSTOREO, ;                  ( decrement the address and store unsigned oct-word o at address a−16 )
alias --h! ( h a -- a−16 )                            ( decrement the address and store signed oct-word h at address a−16 )
alias −−o!  alias −−v!  alias −−2!                    ( aliases with real minus signs )

--- Fetch ---

: b@ ( a -- b )  BFETCH, ;                            ( fetch signed byte from address )
: c@ ( a -- c )  CFETCH, ;                            ( fetch unsigned byte from address )
: s@ ( a -- s )  SFETCH, ;                            ( fetch signed word from address )
: w@ ( a -- w )  WFETCH, ;                            ( fetch unsigned word from address )
: i@ ( a -- i )  IFETCH, ;                            ( fetch signed double word from address )
: d@ ( a -- d )  DFETCH, ;                            ( fetch unsigned double word from address )
: l@ ( a -- l )  QFETCH, ;                            ( fetch signed quad word from address )
: q@ ( a -- q )  QFETCH, ;                            ( fetch unsigned quad word from address )
: h@ ( a -- h )  HFETCH, ;                            ( fetch signed oct word from address )
: o@ ( a -- o )  OFETCH, ;                            ( fetch unsigned oct word from address )

--- Fetch with post-increment ---

: b@++ ( a -- a+1 b )  BFETCHINC, ;                   ( fetch signed byte from address and increment address )
: c@++ ( a -- a+1 c )  CFETCHINC, ;                   ( fetch unsigned byte from address and increment address )
: s@++ ( a -- a+2 s )  SFETCHINC, ;                   ( fetch signed word from address and increment address )
: w@++ ( a -- a+2 w )  WFETCHINC, ;                   ( fetch unsigned word from address and increment address )
: i@++ ( a -- a+4 i )  IFETCHINC, ;                   ( fetch signed double word from address and increment address )
: d@++ ( a -- a+4 d )  DFETCHINC, ;                   ( fetch unsigned double word from address and increment address )
: l@++ ( a -- a+8 l )  LFETCHINC, ;                   ( fetch signed quad word from address and increment address )
: q@++ ( a -- a+8 q )  QFETCHINC, ;                   ( fetch unsigned quad word from address and increment address )
: h@++ ( a -- a+16 h )  HFETCHINC, ;                  ( fetch signed oct word from address and increment address )
: o@++ ( a -- a+16 o )  OFETCHINC, ;                  ( fetch unsigned oct word from address and increment address )

--- Fetch with pre-decrement ---

: −−b@ ( a -- a−1 b )  DECBFETCH, ;  alias --b@       ( decrement address and fetch signed byte at address a−1 )
: −−c@ ( a -- a−1 c )  DECCFETCH, ;  alias --c@       ( decrement address and fetch unsigned byte at address a−1 )
: −−s@ ( a -- a−2 b )  DECSFETCH, ;  alias --s@       ( decrement address and fetch signed word at address a−2 )
: −−w@ ( a -- a−2 w )  DECWFETCH, ;  alias --w@       ( decrement address and fetch unsigned word at address a−2 )
: −−i@ ( a -- a−4 i )  DECIFETCH, ;  alias --i@       ( decrement address and fetch signed double word at address a−4 )
: −−d@ ( a -- a−4 d )  DECDFETCH, ;  alias --d@       ( decrement address and fetch unsigned double word at address a−4 )
: −−l@ ( a -- a−8 l )  DECLFETCH, ;  alias --l@       ( decrement address and fetch signed quad word at address a−8 )
: −−q@ ( a -- a−8 q )  DECQFETCH, ;  alias --q@       ( decrement address and fetch unsigned quad word at address a−8 )
: −−h@ ( a -- a−16 v )  DECHFETCH, ;  alias --h@      ( decrement address and fetch signed oct word at address a−16 )
: −−o@ ( a -- a−16 o )  DECOFETCH, ;  alias --o@      ( decrement address and fetch unsigned oct word at address a−16 )

--- Exchange ---

( Exchange operations are executed atomically, if the hardware provides it.  Usually, this works for values less than or equal
  to the cell size, but is hard to implement for values exceeding the cell size.
)

: b@! ( b a -- b' )  BXCHG, DROP, ;                   ( exchange signed byte b' at address a with b )
: c@! ( c a -- c' )  CXCHG, DROP, ;                   ( exchange unsigned byte c' at address a with c )
: s@! ( s a -- s' )  SXCHG, DROP, ;                   ( exchange signed word s' at address a with s )
: w@! ( w a -- w' )  WXCHG, DROP, ;                   ( exchange unsigned word w' at address a with w )
: i@! ( i a -- i' )  IXCHG, DROP, ;                   ( exchange signed double word i' at address a with i )
: d@! ( d a -- d' )  DXCHG, DROP, ;                   ( exchange unsigned double word d' at address a with d )
: l@! ( l a -- l' )  LXCHG, DROP, ;                   ( exchange signed quad word l' at address a with l )
: q@! ( q a -- q' )  QXCHG, DROP, ;                   ( exchange unsigned quad word q' at address a with q )
: h@! ( h a -- h' )  HXCHG, DROP, ;                   ( exchange signed oct word h' at address a with h )
: o@! ( o a -- o' )  OXCHG, DROP, ;                   ( exchange unsigned oct word o' at address a with o )

: bxchg ( b a -- b' a )  BXCHG, ;                     ( exchange signed byte b' at address a with b )
: cxchg ( c a -- c' a )  CXCHG, ;                     ( exchange unsigned byte c' at address a with c )
: sxchg ( s a -- s' a )  SXCHG, ;                     ( exchange signed word s' at address a with s )
: wxchg ( w a -- w' a )  WXCHG, ;                     ( exchange unsigned word w' at address a with w )
: ixchg ( i a -- i' a )  IXCHG, ;                     ( exchange signed double word i' at address a with i )
: dxchg ( d a -- d' a )  DXCHG, ;                     ( exchange unsigned double word d' at address a with d )
: lxchg ( l a -- l' a )  LXCHG, ;                     ( exchange signed quad word l' at address a with l )
: qxchg ( q a -- q' a )  QXCHG, ;                     ( exchange unsigned quad word q' at address a with q )
: hxchg ( h a -- w' a )  HXCHG, ;                     ( exchange signed oct word h' at address a with h )
: oxchg ( o a -- o' a )  OXCHG, ;                     ( exchange unsigned oct word o' at address a with o )



=== Arithmetic Operations ===

--- Overflow Traps ---

: !! ( -- )  TRAPOV, ;                                ( Trap Int4 on overflow after signed arithemetic operation )
: u!! ( -- )  TRAPCY, ;                               ( Trap Int4 on carry after unsigned arithmetic operation )
: −!! ( -- )  TRAPEZ, ;  alias -!!                    ( Trap Int5 on negative after signed arithmetic operation )

--- Stack Arithmetics ---

: + ( x2 x1 -- x2+x1 )  PLUS, ;                       ( add x1 to x2 )
: − ( x2 x1 -- x2−x1 )  MINUS, ;  alias -             ( subtract x1 from x2 )
: r− ( x2 x1 -- x1−x2 )  RMINUS, ;  alias r-          ( subtract x2 from x1 )
: × ( n2 n1 -- n2×n1 )  TIMES, ;  alias *             ( multiply n2 with n1 — signed multiplication )
: u× ( u2 u1 -- u2×u1 )  UTIMES, ;  alias u*          ( multiply u2 with u1 — unsigned multiplication )
: ÷ ( n2 n1 -- n2÷n1 )  THROUGH, ;  alias /           ( divide n2 through n1 — signed division )
: u÷ ( u2 u1 -- u2÷u1 )  UTHROUGH, ;  alias u/        ( divide u2 through u1 — unsigned division )
: r÷ ( n2 n1 -- n1÷n2 )  RTHROUGH, ;  alias r/        ( divide n1 through n2 — signed division )
: ur÷ ( u2 u1 -- u1÷u2 )  URTHROUGH, ;  alias ur/     ( divide u1 through u2 — unsigned division )
: % ( n2 n1 -- n2%n1 )  MODULO, ;  alias mod          ( Remainder of dividing n2 through n1 — signed division )
: u% ( u2 u1 -- u2%u1 )  UMODULO, ;  alias umod       ( Remainder of dividing u2 through u1 — unsigned division )
: r% ( n2 n1 -- n1%n2 )  RMODULO, ;  alias rmod       ( Remainder of dividing n1 through n2 — signed division )
: ur% ( u2 u1 -- u1%u2 )  URMODULO, ;  alias urmod    ( Remainder of dividing u1 through u2 — unsigned division )
: %÷ ( n2 n1 -- n2%n1 n2÷n1 )  MODDIV, ;  alias /mod  ( Quotient and remainder of dividing n2 through n1 — signed division )
: u%÷ ( u2 u1 -- u2%u1 u2÷u1 )  UMODDIV, ;  alias u/mod    ( Quotient and remainder of dividing u2 through u1 — unsigned div )
: r%÷ ( n2 n1 -- n1%n2 n1÷n2 )  RMODDIV, ;  alias r/mod    ( Quotient and remainder of dividing n1 through n2 — signed div )
: ur%÷ ( u2 u1 -- u1%u2 u1÷u2 )  URMODDIV, ;  alias ur/mod    ( Quotient and remainder of dividing u1 thru u2 — unsigned div )
: ×+ ( n3 n2 n1 -- n )  TIMESPLUS, ;  alias *+        ( n = n3+n2×n1 )
: u×+ ( u3 u2 u1 -- u )  UTIMESPLUS, ;  alias u*+     ( u = u3+u2×u1 )
: ×÷ ( n3 n2 n1 -- n )  TIMESBY, ;  alias */          ( n = n3×n2÷n1, where n3×n2 is a double-cell intermediate result )
: u×÷ ( u3 u2 u1 -- u )  UTIMESBY, ;  alias u*/       ( u = u3×u2÷u1, where u3×u2 is a double-cell intermediate result )
: nxt ( x2 x1 -- x2+1 x1 )  INCS, ;                   ( increment second of stack )
: -> ( a # -- a+1 #-1 )  ADV1, ;                      ( advance cursor in buffer with address a and length # by 1 )
: #-> ( a # u -- a+u #-u )  ADV, ;                    ( advance cursor in buffer with address a and length # by u )
: →| ( n2|0 n1 -- n3|0 )  tuck 1− + over / * ;  alias >|    ( round n2 up to the next multiple of n1, leaving 0 as it is )
: u→| ( u2|0 u1 -- u3|0 )  tuck 1− + over u/ u* ;  alias >|    ( round u2 up to the next multiple of u1, leaving 0 as it is )
: |← ( n2|0 n1 -- n3|0 )  over r% − ;  alias |<       ( round n2 down to the next smaller multiple of n1, leaving 0 as it is )
: u|← ( u2|0 u1 -- u3|0 )  over ur% − ;  alias |<     ( round u2 down to the next smaller multiple of u1, leaving 0 as it is )
: ± ( n -- −n )  NEG, ;  alias negate                 ( negates n )
: abs ( n -- |n| )  ABS, ;                            ( Absolute value of n )
: min ( n2 n1 -- n1|n2 )  MIN2, ;                     ( Lesser of two signed values )
: umin ( u2 u1 -- u1|u2 )  UMIN2, ;                   ( Lesser of two unsigned values )
: max ( n2 n1 -- n1|n2 )  MAX2, ;                     ( Greater of two signed values )
: umax ( u2 u1 -- u1|u2 )  UMAX2, ;                   ( Greater of two unsigned values )
: within ( x xₘᵢₙ xₘₐₓ -- ? )  ISWITHIN, ;            ( test if x is greater or equal than xₘᵢₙ and less than xₘₐₓ )
: nsize ( n -- #|0 )  NSIZE, ;                        ( Size of |n| in bytes, 0 for 0 )
: usize ( u -- #|0 )  USIZE, ;                        ( Size of u in bytes, 0 for 0 )

--- Memory Arithmetics ---

: c+! ( c a -- )  CADD, ;  alias b+!                  ( add c to byte at address a )
: w+! ( w a -- )  WADD, ;  alias s+!                  ( add w to word at address a )
: d+! ( d a -- )  DADD, ;  alias i+!                  ( add d to double word at address a )
: q+! ( q a -- )  QADD, ;  alias l+!                  ( add q to quad word at address a )
: o+! ( o a -- )  OADD, ;  alias v+!                  ( add o to oct word at address a )
: c−! ( c a -- )  CSUB, ;  alias c-!  alias b−!  alias b-!    ( subtract c from byte at address a )
: w−! ( w a -- )  WSUB, ;  alias w-!  alias s−!  alias s-!    ( subtract w from word at address a )
: d−! ( d a -- )  DSUB, ;  alias d-!  alias i−!  alias i-!    ( subtract d from double word at address a )
: q−! ( q a -- )  QSUB, ;  alias q-!  alias l−!  alias l-!    ( subtract q from quad word at address a )
: o−! ( o a -- )  OSUB, ;  alias o-!  alias v−!  alias v-!    ( subtract o from oct word at address a )



=== Condition Tests ===

: 0= ( x -- x=0 )  ISZERO, ;  condition               ( is x zero? )
: 0≠ ( x -- x≠0 )  ISNOTZERO, ;  condition  alias 0−  alias 0-  alias 0<>   ( is x different from zero? )
: 0< ( n -- n<0 )  ISNEGATIVE, ;  condition           ( is n negative, i.e. less than zero? )
: 0> ( n -- n>0 )  ISPOSITIVE, ;  condition           ( is n positive, i.e. greater than zero? )
: 0≤ ( n -- n≤0 )  ISNOTPOSITIVE, ;  condition  alias 0<=   ( is n zero or negative? )
: 0≥ ( n -- n≥0 )  ISNOTNEGATIVE, ;  condition  alias 0>=   ( is n zero or positive? )

: = ( x y -- x=y )  ISEQUAL, ;  condition             ( do x and y have the same value? )
: ≠ ( x y -- x≠y )  ISINIQUAL, ;  condition  alias <> ( do x and y have a different value? )
: < ( n1 n2 -- n1<n2 )  ISLESS, ;  condition          ( is n1 less than n2? signed comparison )
: u< ( u1 u2 -- u1<u2 )  ISBELOW, ;  condition        ( is u1 less than u2? unsigned comparison )
: > ( n1 n2 -- n1>n2 )  ISGREATER, ;  condition       ( is n1 greater than n2? signed comparison )
: u> ( u1 u2 -- u1>u2 )  ISABOVE, ;  condition        ( is u1 greater than u2? unsigned comparison )
: ≤ ( n1 n2 -- n1≤n2 )  ISNOTGREATER, ;  condition  alias <=    ( is n1 less than or equal to n2? signed comparison )
: u≤ ( u1 u2 -- u1≤u2 )  ISNOTABOVE, ;  condition  alias u<=    ( is u1 less than or equal to u2? unsigned comparison )
: ≥ ( n1 n2 -- n1≥n2 )  ISNOTLESS, ;  condition  alias >=       ( is n1 greater than or equal to n2? signed comparison )
: u≥ ( u1 u2 -- u1≥u2 )  ISNOTBELOW, ;  condition  alias u>=    ( is u1 greater than or equal to u2? unsigned comparison )

: ?0= ( x -- x x=0 )  ISZERODUP, ;  condition         ( is x zero? )
: ?0≠ ( x -- x x≠0 )  ISNOTZERODUP, ;  condition  alias ?0−  alias ?0-  alias ?0<>    ( is x different from zero? )
: ?0< ( n -- n n<0 )  ISNEGATIVEDUP, ;  condition     ( is n negative, i.e. less than zero? )
: ?0> ( n -- n n>0 )  ISPOSITIVEDUP, ;  condition     ( is n positive, i.e. greater than zero? )
: ?0≤ ( n -- n n≤0 )  ISNOTPOSITIVEDUP, ;  condition  alias ?0<=    ( is n zero or negative? )
: ?0≥ ( n -- n n≥0 )  ISNOTNEGATIVEDUP, ;  condition  alias ?0>=    ( is n zero or positive? )

: ?= ( x y -- x x=y )  ISEQUALDUP, ;  condition       ( do x and y have the same value? )
: ?≠ ( x y -- x x≠y )  ISINIQUALDUP, ;  condition  alias ?<>    ( do x and y have a different value? )
: ?< ( n1 n2 -- n1 n1<n2 )  ISLESSDUP, ;  condition   ( is n1 less than n2? signed comparison )
: ?u< ( u1 u2 -- u1 u1<u2 )  ISBELOWDUP, ;  condition ( is u1 less than u2? unsigned comparison )
: ?> ( n1 n2 -- n1 n1>n2 )  ISGREATERDUP, ;  condition    ( is n1 greater than n2? signed comparison )
: ?u> ( u1 u2 -- u1 u1>u2 )  ISABOVEDUP, ;  condition ( is u1 greater than u2? unsigned comparison )
: ?≤ ( n1 n2 -- n1 n1≤n2 )  ISNOTGREATERDUP, ;  condition  alias ?<=    ( is n1 less than or equal to n2? signed comparison )
: ?u≤ ( u1 u2 -- u1 u1≤u2 )  ISNOTABOVEDUP, ;  condition  alias ?u<=    ( is u1 less than or equal to u2? unsigned comparison )
: ?≥ ( n1 n2 -- n1 n1≥n2 )  ISNOTLESSDUP, ;  condition  alias ?>=       ( is n1 greater than or equal to n2? signed comparison )
: ?u≥ ( u1 u2 -- u1 u1≥u2 )  ISNOTBELOWDUP, ;  condition  alias ?u>=    ( is u1 greater than or equal to u2? unsigned comparison )

: ??= ( x y -- x y x=y )  ISEQUAL2DUP, ;  condition   ( do x and y have the same value? )
: ??≠ ( x y -- x y x≠y )  ISINIQUAL2DUP, ;  condition  alias ??<>   ( do x and y have a different value? )
: ??< ( n1 n2 -- n1 n2 n1<n2 )  ISLESS2DUP, ;  condition    ( is n1 less than n2? signed comparison )
: ??u< ( u1 u2 -- u1 u2 u1<u2 )  ISBELOW2DUP, ;  condition  ( is u1 less than u2? unsigned comparison )
: ??> ( n1 n2 -- n1 n2 n1>n2 )  ISGREATER2DUP, ;  condition ( is n1 greater than n2? signed comparison )
: ??u> ( u1 u2 -- u1 u2 u1>u2 )  ISABOVE2DUP, ;  condition  ( is u1 greater than u2? unsigned comparison )
: ??≤ ( n1 n2 -- n1 n2 n1≤n2 )  ISNOTGREATER2DUP, ;  condition  alias ??<=  ( is n1 less than or equal to n2? signed comparison )
: ??u≤ ( u1 u2 -- u1 u2 u1≤u2 )  ISNOTABOVE2DUP, ;  condition  alias ??u<=  ( is u1 less than or equal to u2? unsigned comparison )
: ??≥ ( n1 n2 -- n1 n2 n1≥n2 )  ISNOTLESS2DUP, ;  condition  alias ??>=     ( is n1 greater than or equal to n2? signed comparison )
: ??u≥ ( u1 u2 -- u1 u2 u1≥u2 )  ISNOTBELOW2DUP, ;  condition  alias ??u>=  ( is u1 greater than or equal to u2? unsigned comp'son )



=== Logical Stack Operations ===

--- Bitwise Logical Operators ---

: and ( x2 x1 -- x3 )  AND, ;                         ( conjoin aka logically AND two cells )
: or ( x2 x1 -- x3 )  OR, ;                           ( bijoin aka logically OR two cells )
: xor ( x2 x1 -- x3 )  XOR, ;                         ( disjoin aka logically XOR two cells )
: not ( x1 -- ¬x1 )  NOT, ;                           ( 2's complement of a cell )
: andn ( x2 x1 -- x3 )  NOT, AND, ;                   ( conjoin x2 with the 2's complement of x1 )

--- Boolean Operators ---

: && ( x2 x1 -- x3 )  BOOLAND, ;  alias both          ( True if both x2 and x1 are not false, else false )
: || ( x2 x1 -- x3 )  BOOLOR, ;  alias either         ( True if either x2 or x1 or both are not false, else false )
: ^^ ( x2 x1 -- x3 )  BOOLXOR, ;  alias one           ( True if exactly one of x2 and x1 is not false, else false )
: ¬ ( x1 -- x2 )  BOOLNOT, ;          ( alias 0= )    ( True if x1 is false, else false )

--- Shift and Rotate ---

: u<< ( u # -- u' )  SHL, ;  alias u≪                 ( shift u logically left by # bit positions )
: u>> ( u # -- u' )  SHR, ;  alias u≫                 ( shift u logically right by # bit positions )
: << ( n # -- n' )  SHL, ;  alias ≪                   ( shift n arithmetically left by # bit positions )
: >> ( n # -- n' )  SAR, ;  alias ≫                   ( shift n arithmetically right by # bit positions )

--- Stack Bit Operations ---

( Stack bit operations allow bit indices only up to the number of bits in a cell − 1.  The index is moduloed with the cell size
  by the underlying machine code instruction. )

: bit+ ( x # -- x' )  BSET, ;                         ( set bit # in x )
: bit− ( x # -- x' )  BCLR, ;  alias bit-             ( clear bit # in x )
: bit× ( x # -- x' )  BCHG, ;  alias bit*             ( flip bit # in x )
: bit? ( x # -- ? )  BTST, ;                          ( test if bit # in x is set )
: ?bit? ( x # -- x ? )  BTSTX, ;                      ( test if bit # in x is set )
: bit?+ ( x # -- x' ? )  BTSET, ;                     ( non-atomically test and set bit # in x )
: bit?− ( x # -- x' ? )  BTCLR, ;  alias bit?-        ( non-atomically test and clear bit # in x )
: bit?× ( x # -- x' ? )  BTCHG, ;  alias bit?*        ( non-atomically test and flip bit # in x )
: bit?? ( x # -- x ? )  BTTST, ;                      ( test if bit # in x is set )
: bita?+ ( x # -- x' ? )  ABTSET, ;                   ( atomically test and set bit # in x )
: bita?− ( x # -- x' ? )  ABTCLR, ;  alias bita?-     ( atomically test and clear bit # in x )
: bita?× ( x # -- x' ? )  ABTCHG, ;  alias bita?*     ( atomically test and flip bit # in x )

--- Memory Bit Operations ---

( Memory bit operations can have quite a big bit index, allowing for potentially huge bit arrays.  The bit index is divided
  through 8 and the result added to the address, then moduloed with 8 to get the bit index in the addressed byte. )

: bit+! ( a # -- )  BSETAT, ;                         ( set bit # at address a )
: bit−! ( a # -- )  BCLRAT, ;  alias bit-!            ( clear bit # at address a )
: bit×! ( a # -- )  BCHGAT, ;  alias bit*!            ( flip bit # at address a )
: bit@ ( a # -- ? )  BTSTAT, ;                        ( test if bit # at address a is set )
: bit@+! ( a # -- ? )  BTSETAT, ;                     ( non-atomically test and set bit # at address a )
: bit@−! ( a # -- ? )  BTSETAT, ;  alias bit@-!       ( non-atomically test and clear bit # at address a )
: bit@×! ( a # -- ? )  BTSETAT, ;  alias bit@*!       ( non-atomically test and flip bit # at address a )
: bita@+! ( a # -- ? )  ABTSETAT, ;                   ( atomically test and set bit # at address a )
: bita@−! ( a # -- ? )  ABTSETAT, ;  alias bita@-!    ( atomically test and clear bit # at address a )
: bita@×! ( a # -- ? )  ABTSETAT, ;  alias bita@*!    ( atomically test and flip bit # at address a )



=== Block Operations ===

( In the following block operations, length # is measured in the unit of the block element, e.g. in wfill, the block is # WORDS
  long, not # bytes.
)

--- Block Fill ---

: cfill ( a # c -- )  CFILL, ;                        ( fill block with length # at address a with byte c )
: wfill ( a # w -- )  WFILL, ;                        ( fill block with length # at address a with word w )
: dfill ( a # d -- )  DFILL, ;                        ( fill block with length # at address a with double word d )
: qfill ( a # q -- )  QFILL, ;                        ( fill block with length # at address a with quad word q )
: ofill ( a # o -- )  OFILL, ;                        ( fill block with length # at address a with oct word o )

--- Block Scan ---

( The result of block scans is the index *after* the occurrence, or 0 if no occurrence was found. )

: cfind> ( a # c -- u )  CFIND, ;                     ( lookup first occurrence of byte c in block at a with length # )
: wfind> ( a # w -- u )  WFIND, ;                     ( lookup first occurrence of word w in block at a with length # )
: dfind> ( a # d -- u )  DFIND, ;                     ( lookup first occurrence of double word d in block at a with length # )
: qfind> ( a # q -- u )  QFIND, ;                     ( lookup first occurrence of quad word q in block at a with length # )
: ofind> ( a # o -- u )  OFIND, ;                     ( lookup first occurrence of oct word o in block at a with length # )

--- Block Move ---

( Block moves automatically determine, in which direction the move has to occur so as to not overwrite elements that have not
  yet been moved.
)

: cmove ( sa ta # -- )  CMOVE, ;                      ( move # bytes from block at sa to block at ta )
: wmove ( sa ta # -- )  WMOVE, ;                      ( move # words from block at sa to block at ta )
: dmove ( sa ta # -- )  DMOVE, ;                      ( move # double words from block at sa to block at ta )
: qmove ( sa ta # -- )  QMOVE, ;                      ( move # quad words from block at sa to block at ta )
: omove ( sa ta # -- )  2u* QMOVE, ;                  ( move # oct words from block at sa to block at ta )



=== String Operations ===

--- UTF-8 Operations ---

( In UTF-8 operations, "length" measures the string in UTF-8 characters, not bytes.
  The typical error condition — trying to read past the end of the buffer, or invalid UTF-8 character — is signaled with -1
  instead of a uc, since -1 is not valid in UTF-8, whereas 0 is.
)

------
: c$@++ ( a -- a' uc|-1 )  FETCHUC$INC, ;             ( read next UTF-8 character uc from buffer at address a, and increment )
: $# ( a -- # )  c$@++ nip ;                          ( Length # of UTF-8 string at address a )
: $count ( a$ -- a # )  FETCHUC$INC, ;                ( Address and Length of counted UTF-8 string )
: 0count ( aº -- a # )  dup begin c$++ 0= until  1 − over − ;          ( Address and Length of zero-terminated UTF-8 string )
: $= ( $1 $2 -- ? )                                   ( check if two UTF-8 strings are equal )
  c$@++ rot c$@++ rot over = if
    0 udo  c$@++ rot c$@++ rot = unlessever  2 #drop false exitloop  then  loop
    2 #drop true exit  then
  3 #drop false ;        
: c$>> ( a # -- a' #−1 uc|-1 || a 0 -1 )              ( read next UFT-8 character from buffer a/#, or return -1 if not OK )
  dup unlessever  dup 1 −  else  swap c$@++ rot 1 − swap  then ;        
------

: c$@++ ( a # -- a' #' uc|-1 )  GETUC, ;              ( read next UTF-8 char uc from buffer at a with length #, and advance )
: $# ( $ -- #|-1 )  8 c$@++ -rot 2drop ;              ( Length of UTF-8 string $, or -1 if the length is invalid )
: $count ( $ -- a #|-1 )  8 c$@++ nip ;               ( Address a and Length # of counted UTF-8 string $, -1 if invalid )
: 0count ( a⁰ -- a #|-1 )
  dup -1 begin  c$@++  1 < until  ?dup -1 = if  2nip exit  then  drop 1 − over − ;        


=== Various ===

--- Code execution ---

: execute ( cfa -- )  EXECUTE, ;                      ( execute the code at the specified cfa )
: execWord ( @w -- )  EXECUTEWORD, ;                  ( execute code of word @w )



=== Module Initialization ===

init: ( @initstr -- @initstr )  dup @PSP + q@ 8− PSP0 q!  dup @RSP + q@ 32+ RSP0 q! ;

vocabulary; quit



=== Test Code ===

tests:

  test: cell: checks if cell size conforms with current architecture.
  given sp0!
  when: cell
  then: TARGET_ARCH_CELL_SIZE !=
        depth 0 !=
  test;

  test: %cell: checks if cell shift conforms with current architecture.
  given sp0!
  when: %cell
  then: TARGET_ARCH_CELL_SIZE 8* !=
        depth 0 !=
  test;

  test: cell+: checks if cell addition is correct.
  given sp0!  24
  when: cell+
  then: TARGET_ARCH_CELL_SIZE 24 + !=
        depth 0 !=
  test;

  test: cell+: checks if cell+ fails gracefully on an empty stack.
  given sp0!
  when: capture{ cell+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: cells: checks if cell multiplication is correct.
  given sp0!  24
  when: cells
  then: TARGET_ARCH_CELL_SIZE 24 u* !=
        depth 0 !=
  test;

  test: cells: checks if cells fails gracefully on an empty stack.
  given sp0!
  when: capture{ cells }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: cells+: checks if cell multadd is correct.
  given sp0!  100 24
  when: cells+
  then: TARGET_ARCH_CELL_SIZE 24 u* 100 + !=
        depth 0 !=
  test;

  test: cells+: checks if cells+ fails gracefully on an empty stack.
  given sp0!
  when: capture{ cells+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: cells+: checks if cells+ fails gracefully on a stack with only one entry.
  given sp0!  222
  when: capture{ cells+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: cellu/: checks if cell size division is correct.
  given sp0!  1024
  when: cellu/
  then: 1024 TARGET_ARCH_CELL_SIZE u/ !=
        depth 0 !=
  test;

  test: cellu/: checks if cellu/ fails gracefully on an empty stack.
  given sp0!
  when: capture{ cellu/ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: 0: checks if constant 0 is pushed.
  given sp0!
  when: 0
  then: 0 !=
        depth 0 !=
  test;

  test: d#0: checks if constant d#0 is pushed.
  given sp0!
  when: d#0
  then: d0 !=
        depth 0 !=
  test;

  test: q#0: checks if constant q#0 is pushed.
  given sp0!
  when: q#0
  then: q0 !=
        depth 0 !=
  test;

  test: o#0: checks if constant o#0 is pushed.
  given sp0!
  when: o#0
  then: o0 !=
        depth 0 !=
  test;

  test: 1: checks if constant 1 is pushed.
  given sp0!
  when: 1
  then: 1 !=
        depth 0 !=
  test;

  test: d#1: checks if constant d#1 is pushed.
  given sp0!
  when: d#1
  then: 1 d!=
        depth 0 !=
  test;

  test: q#1: checks if constant q#1 is pushed.
  given sp0!
  when: q#1
  then: 1 q!=
        depth 0 !=
  test;

  test: o#1: checks if constant o#1 is pushed.
  given sp0!
  when: o#1
  then: 1 o!=
        depth 0 !=
  test;

  test: -1: checks if constant -1 is pushed.
  given sp0!
  when: -1
  then: -1 !=
        depth 0 !=
  test;

  test: d#−1: checks if constant d#−1 is pushed.
  given sp0!
  when: d#−1
  then: −1 d!=
        depth 0 !=
  test;

  test: q#−1: checks if constant q#−1 is pushed.
  given sp0!
  when: q#−1
  then: −1 q!=
        depth 0 !=
  test;

  test: o#−1: checks if constant o#−1 is pushed.
  given sp0!
  when: o#−1
  then: −1 o!=
        depth 0 !=
  test;

  test: bl: checks if a blank is pushed.
  given sp0!
  when: bl
  then: $20 !=
        depth 0 !=
  test;

  test: sp0: checks if the initial stack pointer is returned.
  given sp0!
  when: sp0
  then: PSP0 @ !=
        depth 0 !=
  test;

  test: sp@: checks if the stack pointer on an empty stack is equal to initial SP, and decreases by 1 cell when pushing.
  given sp0!
  when: sp@ sp@
  then: sp0 cell - !=
        sp0 !=
        depth 0 !=
  test;

  test: sp!: checks if the stack pointer is set to sp.
  given 1024 sp!
  when: sp@
  then: 1024 !=
        depth 1024 !=
  @end: sp0!
  test;

  test: sp!: checks if sp! fails gracefully on an empty stack.
  given sp0!
  when: capture{ sp! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: sp0!: checks if the stack pointer is reset to zero.
  given 0 1 2 3 4 5 6 7 8 9
  when: sp0!
  then: sp@ sp0 !=
        depth 0 !=
  test;

  test: sp#: checks if the stack can be set to the bottom.
  given sp0!
  when: sp0 sp# cells - sp!
  then: capture{ dup }capture sp0!
        captured@ ParameterStackOverflow !=
  test;

  test: sp##: checks if the stack can be set to the bottom.
  given sp0!
  when: sp0 sp## - sp!
  then: capture{ dup }capture sp0!
        captured@ ParameterStackOverflow !=
  test;

  test: depth: checks if the initial depth is 0.
  given sp0!
  when: depth
  then: 0 !=
        depth 0 !=
  test;

  test: depth: checks if the depth is correctly reported.
  given sp0! 1 2 3
  when: depth
  then: 3 !=
        depth 0 !=
  test;

  test: dup: checks if the current entry is duplicated.
  given sp0! 12345678
  when: dup
  then: !=
        depth 0 !=
  test;

  test: dup: checks if dup fails gracefully on an empty stack.
  given sp0!
  when: capture{ dup }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: drop: checks if the current entry is dropped.
  given sp0! 12345678
  when: drop
  then: depth 0 !=
  test;

  test: drop: checks if drop fails gracefully on an empty stack.
  given sp0!
  when: capture{ drop }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: swap: checks if the TOP and 2OP are swapped.
  given sp0! 12345678 45645645
  when: swap
  then: 12345678 !=
        45645645 !=
        depth 0 !=
  test;

  test: swap: checks if swap fails gracefully on an empty stack.
  given sp0!
  when: capture{ swap }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: swap: checks if swap fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ swap }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: over: checks if the 2OP is copied over the TOP.
  given sp0! 12345678 45645645
  when: over
  then: 12345678 !=
        45645645 !=
        12345678 !=
        depth 0 !=
  test;

  test: over: checks if over fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ swap }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: over: checks if over fails gracefully on an empty stack.
  given sp0!
  when: capture{ over }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: over: checks if over fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ over }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: tuck: checks if the TOP is copied under the 2OP.
  given sp0! 45645645 12345678
  when: tuck
  then: 12345678 !=
        45645645 !=
        12345678 !=
        depth 0 !=
  test;

  test: tuck: checks if tuck fails gracefully on an empty stack.
  given sp0!
  when: capture{ tuck }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: tuck: checks if tuck fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ tuck }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: nip: checks if the 2OP is dropped.
  given sp0! 45645645 12345678
  when: nip
  then: 12345678 !=
        depth 0 !=
  test;

  test: nip: checks if nip fails gracefully on an empty stack.
  given sp0!
  when: capture{ nip }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: nip: checks if nip fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ nip }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: rot: checks if the stack triple is rotated.
  given sp0! 45645645 12345678 -9897363
  when: rot
  then: 45645645 !=
        -9897363 !=
        12345678 !=
        depth 0 !=
  test;

  test: rot: checks if rot fails gracefully on an empty stack.
  given sp0!
  when: capture{ rot }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: rot: checks if rot fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ rot }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: rot: checks if rot fails gracefully on a stack with only two entries.
  given sp0!  2134155 453465
  when: capture{ rot }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: -rot: checks if the stack triple is rotated.
  given sp0! 45645645 12345678 -9897363
  when: -rot
  then: 12345678 !=
        45645645 !=
        -9897363 !=
        depth 0 !=
  test;

  test: -rot: checks if -rot fails gracefully on an empty stack.
  given sp0!
  when: capture{ -rot }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: -rot: checks if -rot fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ -rot }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: -rot: checks if -rot fails gracefully on a stack with only two entries.
  given sp0!  2134155 453465
  when: capture{ -rot }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: 2dup: checks if the top stack pair is duplicated.
  given sp0! 45645645 12345678
  when: -rot
  then: 12345678 !=
        45645645 !=
        12345678 !=
        45645645 !=
        depth 0 !=
  test;

  test: 2dup: checks if 2dup fails gracefully on an empty stack.
  given sp0!
  when: capture{ 2dup }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: 2dup: checks if 2dup fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ 2dup }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: 2drop: checks if the top stack pair is dropped.
  given sp0! 45645645 12345678
  when: 2drop
  then: depth 0 !=
  test;

  test: 2drop: checks if 2drop fails gracefully on an empty stack.
  given sp0!
  when: capture{ 2drop }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: 2drop: checks if 2drop fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ 2drop }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: 2swap: checks if the top stack pair is swapped with the next stack pair.
  given sp0! 45645645 -12345678 -9897363 222222222
  when: 2drop
  then: -12345678 !=
        45645645 !=
        222222222 !=
        -9897363 !=
        depth 0 !=
  test;

  test: 2swap: checks if 2swap fails gracefully on an empty stack.
  given sp0!
  when: capture{ 2swap }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: 2swap: checks if 2swap fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ 2swap }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: 2swap: checks if 2swap fails gracefully on a stack with only two entries.
  given sp0!  2134155 0
  when: capture{ 2swap }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: 2swap: checks if 2swap fails gracefully on a stack with only three entries.
  given sp0!  2134155 0 -1
  when: capture{ 2swap }capture
  then: captured@ ParameterStackUnderflow !=
        depth 3 !=
  test;

  test: 2over: checks if the second stack pair is copied over the top stack pair.
  given sp0! 45645645 -12345678 -9897363 222222222
  when: 2drop
  then: -12345678 !=
        45645645 !=
        222222222 !=
        -9897363 !=
        -12345678 !=
        45645645 !=
        depth 0 !=
  test;

  test: 2over: checks if 2over fails gracefully on an empty stack.
  given sp0!
  when: capture{ 2over }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: 2over: checks if 2over fails gracefully on a stack with only one entry.
  given sp0!  2134155
  when: capture{ 2over }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: 2over: checks if 2over fails gracefully on a stack with only two entries.
  given sp0!  2134155 0
  when: capture{ 2over }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: 2over: checks if 2over fails gracefully on a stack with only three entries.
  given sp0!  2134155 0 -1
  when: capture{ 2over }capture
  then: captured@ ParameterStackUnderflow !=
        depth 3 !=
  test;

  test: pick: checks if the uth element is picked from the stack.
  given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
  when: 5 pick
  then: 12345678 !=
        depth 7 !=
  test;

  test: pick: checks if pick succeeds on a stack with u and exactly u+1 entries.
  given sp0!
  when: 0 1 2 3 4 4 pick
  then: 0 !=
        depth 3 !=
  test;

  test: pick: checks if pick fails gracefully on an empty stack.
  given sp0!
  when: capture{ pick }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: pick: checks if pick fails gracefully on an empty stack with u.
  given sp0!
  when: capture{ 4 pick }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: pick: checks if pick fails gracefully on an empty stack with u and u-1 entries.
  given sp0!
  when: capture{ 1 2 3 4 4 pick }capture
  then: captured@ ParameterStackUnderflow !=
        depth 4 !=
  test;

  test: roll: checks if the stack is rotated around u cells.
  given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
  when: 5 roll
  then: -9897363 !=
        666666666 !=
        55555555555 !=
        -234265446 !=
        222222222 !=
        -9897363 !=
        12345678 !=
        45645645 !=
        depth 7 !=
  test;

  test: roll: checks if roll fails gracefully on an empty stack.
  given sp0!
  when: capture{ roll }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: roll: checks if roll succeeds on a stack with u and exactly u entries.
  given sp0!
  when: 0 1 2 3 4 roll
  then: 0 !=
        depth 3 !=
  test;

  test: roll: checks if roll fails gracefully on an empty stack with u.
  given sp0!
  when: capture{ 4 roll }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: roll: checks if roll fails gracefully on an empty stack with u and u-1 entries.
  given sp0!
  when: capture{ 1 2 3 4 roll }capture
  then: captured@ ParameterStackUnderflow !=
        depth 4 !=
  test;

  test: -roll: checks if the stack is rotated around u cells.
  given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
  when: 5 -roll
  then: 55555555555 !=
        -234265446 !=
        222222222 !=
        -9897363 !=
        666666666 !=
        12345678 !=
        45645645 !=
        depth 7 !=
  test;

  test: -roll: checks if -roll succeeds on a stack with u and exactly u entries.
  given sp0!
  when: 0 1 2 3 4 roll
  then: 2 !=
        depth 3 !=
  test;

  test: -roll: checks if -roll fails gracefully on an empty stack.
  given sp0!
  when: capture{ -roll }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: -roll: checks if -roll fails gracefully on an empty stack with u.
  given sp0!
  when: capture{ 4 -roll }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: -roll: checks if -roll fails gracefully on an empty stack with u and u-1 entries.
  given sp0!
  when: capture{ 1 2 3 4 -roll }capture
  then: captured@ ParameterStackUnderflow !=
        depth 4 !=
  test;

  test: ?dup: checks if duped if not 0.
  given sp0! 345236576
  when: ?dup
  then: !=
        depth 0 !=
  test;

  test: ?dup: checks if not duped if 0.
  given sp0! 0
  when: ?dup
  then: 0 !=
        depth 0 !=
  test;

  test: ?dup: checks if ?dup fails gracefully on an empty stack.
  given sp0!
  when: capture{ ?dup }capture
  then: captured@ ParameterStackUnderflow !=
  test;

  test: rp0: checks if the initial stack pointer is returned.
  given sp0!
  when: rp0
  then: RSP0 @ !=
        depth 0 !=
  test;

  test: rp@: checks if the stack pointer increases by 1 cell when pushing.
  given sp0!
  when: rp@ 0 >r rp@ rdrop
  then: cell - 0 !=
        depth 0 !=
  test;

  test: rp!: checks if the stack pointer is set correctly.
  given sp0!
  when: rp@ cell+ rp! rp@ rdrop
  then: cell - !=
        depth 0 !=
  test;

  test: r>: checks if the return stack element appears on the parameter stack and that rp is decreased.
  given sp0!
  when: rp@  123435467 >r r>  rp@ swap
  then: 123435467 !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if r> gracefully fails on an empty return stack )

  test: >r: checks if the parameter stack element appears on the return stack and that rp is increased.
  given sp0! 123435467
  when: rp@ swap >r rp@ r>
  then: 123435467 !=
        cell - !=
        depth 0 !=
  test;

  ( TODO if possible: test if >r gracefully fails on an empty parameter stack )

  test: r@: checks if the return stack element appears on the parameter stack and that rp is not decreased.
  given sp0!
  when: rp@  123435467 >r r@ r>  rp@ -rot
  then: !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if r@ gracefully fails on an empty return stack )

  test: r!: checks if a copy of the parameter stack element appears on the return stack and that rp is decreased.
  given sp0!  123435467
  when: rp@ swap r! r> ( rp' x x |R: ) rp@ -rot
  then: !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if >r gracefully fails on an empty parameter stack )

  test: rdrop: checks if the return stack element is dropped.
  given sp0!  123435467
  when: rp@ swap >r rdrop ( rp' |R: ) rp@
  then: !=
        depth 0 !=
  test;

  test: rdup: checks if a copy of the return stack element appears on the return stack and the return stack is decreased.
  given sp0!
  when: rp@ rdup r> r@ ( rp' x x |R: ) rp@ -rot
  then: !=
        !=
        depth 0 !=
  test;

  test: i: checks if the index appears on the parameter stack and the return stack is unchanged.
  given sp0!  12345678 >r -981765814 >r
  when: rp@ i rp@ swap rdrop rdrop
  then: -981765814 !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if i gracefully fails on an empty return stack and a return stack with only one element*
         * this prevents from i to be inadvertently used outside of a loop [instead of r@] )

  test: limit: checks if the limit appears on the parameter stack and the return stack is unchanged.
  given sp0!  12345678 >r -981765814 >r
  when: rp@ limit rp@ swap rdrop rdrop
  then: 12345678 !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if limit gracefully fails on an empty return stack and a return stack with only one element )

  test: j: checks if the outer index appears on the parameter stack and the return stack is unchanged.
  given sp0!  12345678 >r -981765814 >r 666666666 >r 77777777 >r
  when: rp@ j rp@ swap rdrop rdrop rdrop rdrop
  then: -981765814 !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if j gracefully fails on an empty return stack and a return stack with less than 4 elements*
         * see also to-do on i )

  test: ljmit: checks if the outer index appears on the parameter stack and the return stack is unchanged.
  given sp0!  12345678 >r -981765814 >r 666666666 >r 77777777 >r
  when: rp@ j rp@ swap rdrop rdrop rdrop rdrop
  then: 12345678 !=
        !=
        depth 0 !=
  test;

  ( TODO if possible: test if ljmit gracefully fails on an empty return stack and a return stack with less than 4 elements )

  test: unloop: checks if the index and limit are dropped from the return stack.
  given sp0!  12345678 >r -981765814 >r
  when: rp@ unloop rp@
  then: 2 cells + !=
        depth 0 !=
  test;

  ( TODO if possible: test if unloop gracefully fails on an empty return stack and a return stack with only one element )

  test: rdepth: checks if the return stack depth is correctly reported.
  given sp0!
  when: rp@ rp0 - cellu/ rdepth
  then: !=
        depth 0 !=
  test;

  test: !OV: check if overflow triggers trap.
  given MAX_I 2
  when: capture{ + !OV }capture
  then: captured@ ArithmeticOverflow !=
        depth 0 !=
  test;

  test: !OV: check if non-overflow doesn't trigger trap.
  given 1 2
  when: capture{ − !OV }capture
  then: captured@ 0 !=
        -1 !=
        depth 0 !=
  test;

  test: !CY: check if carry triggers trap.
  given MAX_C 2
  when: capture{ + !O! }capture
  then: captured@ ArithmeticOverflow !=
        depth 0 !=
  test;

  test: !CY: check if borrow triggers trap.
  given MAX_C 2
  when: capture{ r− !C! }capture
  then: captured@ ArithmeticOverflow !=
        depth 0 !=
  test;

  test: !CY: check if non-carry doesn't trigger trap (even when overflow).
  given MAX_I 2
  when: capture{ + !C! }capture
  then: captured@ 0 !=
        drop
        depth 0 !=
  test;

  test: +: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: +
  then: 4753 !=
        depth 0 !=
  test;

  test: +: checks if + fails gracefully on an empty stack.
  given sp0!
  when: capture{ + }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: +: checks if + fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ + }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: −: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: −
  then: -4660 !=
        depth 0 !=
  test;

  test: −: checks if − fails gracefully on an empty stack.
  given sp0!
  when: capture{ − }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −: checks if − fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ − }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: r−: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: r−
  then: 4660 !=
        depth 0 !=
  test;

  test: r−: checks if r− fails gracefully on an empty stack.
  given sp0!
  when: capture{ r− }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: r−: checks if r− fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ r− }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ×: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: ×
  then: 197,862 !=
        depth 0 !=
  test;

  test: ×: checks if the result is arithmetically correct.
  given sp0!  -13 -12
  when: ×
  then: 156 !=
        depth 0 !=
  test;

  test: ×: checks if × fails gracefully on an empty stack.
  given sp0!
  when: capture{ × }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ×: checks if × fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ × }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u×: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: ×
  then: 197,862 !=
        depth 0 !=
  test;

  test: u×: checks if the result is arithmetically correct.
  given sp0!  -13 -12
  when: ×
  then: 156 !=
        depth 0 !=
  test;

  test: u×: checks if u× fails gracefully on an empty stack.
  given sp0!
  when: capture{ u× }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u×: checks if u× fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u× }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ÷: checks if the result is arithmetically correct.
  given sp0!  −4711 42
  when: ÷
  then: −112 !=
        depth 0 !=
  test;

  test: ÷: checks if ÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ÷: checks if ÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ ÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u÷: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: u÷
  then: 112 !=
        depth 0 !=
  test;

  test: u÷: checks if u÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ u÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u÷: checks if u÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: r÷: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: r÷
  then: 112 !=
        depth 0 !=
  test;

  test: r÷: checks if r÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ r÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: r÷: checks if r÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ r÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ur÷: checks if the result is arithmetically correct.
  given sp0!  −42 4711
  when: ur÷
  then: −112 !=
        depth 0 !=
  test;

  test: ur÷: checks if ur÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ur÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ur÷: checks if ur÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ ur÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: %: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: %
  then: 7 !=
        depth 0 !=
  test;

  test: %: checks if % fails gracefully on an empty stack.
  given sp0!
  when: capture{ % }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: %: checks if % fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ % }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u%: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: u%
  then: 7 !=
        depth 0 !=
  test;

  test: u%: checks if u% fails gracefully on an empty stack.
  given sp0!
  when: capture{ u% }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u%: checks if u% fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u% }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: r%: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: r%
  then: 7 !=
        depth 0 !=
  test;

  test: r%: checks if r% fails gracefully on an empty stack.
  given sp0!
  when: capture{ r% }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: r%: checks if r% fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ r% }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ur%: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: ur%
  then: 7 !=
        depth 0 !=
  test;

  test: ur%: checks if ur% fails gracefully on an empty stack.
  given sp0!
  when: capture{ ur% }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ur%: checks if ur% fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ ur% }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: %÷: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: %÷
  then: 112 !=
        7 !=
        depth 0 !=
  test;

  test: %÷: checks if %÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ %÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: %÷: checks if %÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ %÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u%÷: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: u÷
  then: 112 !=
        7 !=
        depth 0 !=
  test;

  test: u%÷: checks if u%÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ u%÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u%÷: checks if u%÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u%÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: r%÷: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: r÷
  then: 112 !=
        7 !=
        depth 0 !=
  test;

  test: r%÷: checks if r%÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ r%÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: r%÷: checks if r%÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ r%÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ur%÷: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: ur÷
  then: 112 !=
        7 !=
        depth 0 !=
  test;

  test: ur%÷: checks if ur%÷ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ur%÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ur%÷: checks if ur%÷ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ ur%÷ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ×+: checks if the result is arithmetically correct.
  given sp0!  4711 42 13
  when: ×+
  then: 5257 !=
        depth 0 !=
  test;

  test: ×+: checks if ×+ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ×+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ×+: checks if ×+ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ ×+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ×+: checks if ×+ fails gracefully on a stack with only two entries.
  given sp0!  4711 42
  when: capture{ ×+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: u×+: checks if the result is arithmetically correct.
  given sp0!  4711 42 13
  when: u×+
  then: 5257 !=
        depth 0 !=
  test;

  test: u×+: checks if u×+ fails gracefully on an empty stack.
  given sp0!
  when: capture{ u×+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u×+: checks if u×+ fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u×+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u×+: checks if u×+ fails gracefully on a stack with only two entries.
  given sp0!  4711 42
  when: capture{ u×+ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  ( TODO tests for ×÷ and u×÷ )

  test: nxt: checks if the result is arithmetically correct.
  given sp0!  42 13
  when: nxt
  then: 13 !=
        43 !=
        depth 0 !=
  test;

  test: nxt: checks if nxt fails gracefully on an empty stack.
  given sp0!
  when: capture{ nxt }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: nxt: checks if nxt fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ nxt }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: +>: checks if both 2OP and TOP are affected in the right direction.
  given sp0!  42 13
  when: 12 +>
  then: 1 !=
        54 !=
        depth 0 !=
  test;

  test: +>: checks if +> fails gracefully on an empty stack.
  given sp0!
  when: capture{ +> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: +>: checks if +> fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ +> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: +>: checks if +> fails gracefully on a stack with only two entries.
  given sp0!  42 13
  when: capture{ +> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: →|: checks if the result is arithmetically correct.
  given sp0!  42
  when: 8 →|
  then: 48 !=
        depth 0 !=
  test;

  test: →|: checks if the result is arithmetically correct.
  given sp0!  -42
  when: 8 →|
  then: -40 !=
        depth 0 !=
  test;

  test: →|: asserts that 0 is not advanced.
  given sp0!  0
  when: 8 →|
  then: 0 !=
        depth 0 !=
  test;

  test: →|: checks if →| fails gracefully on an empty stack.
  given sp0!
  when: capture{ →| }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: →|: checks if →| fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ →| }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u→|: checks if the result is arithmetically correct.
  given sp0!  42
  when: 8 u→|
  then: 48 !=
        depth 0 !=
  test;

  test: u→|: checks if the result is arithmetically correct.
  given sp0!  -42
  when: 8 →|
  then: -40 !=
        depth 0 !=
  test;

  test: u→|: checks if u→| fails gracefully on an empty stack.
  given sp0!
  when: capture{ u→| }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u→|: asserts that 0 is not touched.
  given sp0!  0
  when: 8 u→|
  then: 0 !=
        depth 0 !=
  test;

  test: u→|: checks if u→| fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u→| }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: |←: checks if the result is arithmetically correct.
  given sp0!  42
  when: 8 |←
  then: 40 !=
        depth 0 !=
  test;

  test: |←: checks if the result is arithmetically correct.
  given sp0!  -42
  when: 8 |←
  then: -48 !=
        depth 0 !=
  test;

  test: |←: asserts that 0 is not touched.
  given sp0!  0
  when: 8 |←
  then: 0 !=
        depth 0 !=
  test;

  test: |←: checks if |← fails gracefully on an empty stack.
  given sp0!
  when: capture{ |← }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: |←: checks if |← fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ |← }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u|←: checks if the result is arithmetically correct.
  given sp0!  42
  when: 8 u|←
  then: 40 !=
        depth 0 !=
  test;

  test: u|←: checks if the result is arithmetically correct.
  given sp0!  -42
  when: 8 u|←
  then: -48 !=
        depth 0 !=
  test;

  test: u|←: asserts that 0 is not touched.
  given sp0!  0
  when: 8 u|←
  then: 0 !=
        depth 0 !=
  test;

  test: u|←: checks if u|← fails gracefully on an empty stack.
  given sp0!
  when: capture{ u|← }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u|←: checks if u|← fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u|← }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ±: checks if the result is arithmetically correct.
  given sp0!  4711
  when: ±
  then: -4711 !=
        depth 0 !=
  test;

  test: ±: checks if the result is arithmetically correct.
  given sp0!  -42
  when: ±
  then: 42 !=
        depth 0 !=
  test;

  test: ±: checks if ± fails gracefully on an empty stack.
  given sp0!
  when: capture{ ± }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: abs: checks if the result is arithmetically correct.
  given sp0!  4711
  when: abs
  then: 4711 !=
        depth 0 !=
  test;

  test: abs: checks if the result is arithmetically correct.
  given sp0!  -42
  when: abs
  then: 42 !=
        depth 0 !=
  test;

  test: abs: checks if abs fails gracefully on an empty stack.
  given sp0!
  when: capture{ abs }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: min: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: min
  then: 42 !=
        depth 0 !=
  test;

  test: min: checks if the result is arithmetically correct.
  given sp0!  -4711 42
  when: min
  then: -4711 !=
        depth 0 !=
  test;

  test: min: checks if min fails gracefully on an empty stack.
  given sp0!
  when: capture{ min }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: min: checks if min fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ min }capture
  then: captured@ ParameterStackUnderflow !=
        depth !1=
  test;

  test: umin: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: umin
  then: 42 !=
        depth 0 !=
  test;

  test: umin: checks if the result is arithmetically correct.
  given sp0!  -4711 42
  when: min
  then: 42 !=
        depth 0 !=
  test;

  test: umin: checks if umin fails gracefully on an empty stack.
  given sp0!
  when: capture{ umin }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: umin: checks if umin fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ umin }capture
  then: captured@ ParameterStackUnderflow !=
        depth !1=
  test;

  test: max: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: max
  then: 4711 !=
        depth 0 !=
  test;

  test: max: checks if the result is arithmetically correct.
  given sp0!  -4711 42
  when: max
  then: 42 !=
        depth 0 !=
  test;

  test: max: checks if max fails gracefully on an empty stack.
  given sp0!
  when: capture{ max }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: max: checks if max fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ max }capture
  then: captured@ ParameterStackUnderflow !=
        depth !1=
  test;

  test: umax: checks if the result is arithmetically correct.
  given sp0!  4711 42
  when: umax
  then: 4711 !=
        depth 0 !=
  test;

  test: umax: checks if the result is arithmetically correct.
  given sp0!  -4711 42
  when: umax
  then: -4711 !=
        depth 0 !=
  test;

  test: umax: checks if umax fails gracefully on an empty stack.
  given sp0!
  when: capture{ umax }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: umax: checks if umax fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ umax }capture
  then: captured@ ParameterStackUnderflow !=
        depth !1=
  test;

  test: within: checks if the test is correct when x is between.
  given sp0!
  when: 4 2 8 within
  then: true !=
        depth 0 !=
  test;

  test: within: checks if the test is correct when x is lower.
  given sp0!
  when: -4 2 8 within
  then: false !=
        depth 0 !=
  test;

  test: within: checks if the test is correct when x is higher.
  given sp0!
  when: 14 2 8 within
  then: false !=
        depth 0 !=
  test;

  test: within: checks if the test is correct when x is xmax.
  given sp0!
  when: 8 2 8 within
  then: false !=
        depth 0 !=
  test;

  test: within: checks if the test is correct when x is xmin.
  given sp0!
  when: 2 2 8 within
  then: true !=
        depth 0 !=
  test;

  test: within: checks if the test is correct when x is negative and in range.
  given sp0!
  when: -2 -8 8 within
  then: true !=
        depth 0 !=
  test;

  test: within: checks if within fails gracefully on an empty stack.
  given sp0!
  when: capture{ within }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: within: checks if within fails gracefully on a stack with only one entry.
  given sp0!  1
  when: capture{ within }capture
  then: captured@ ParameterStackUnderflow !=
        depth !1=
  test;

  test: within: checks if within fails gracefully on a stack with only two entries.
  given sp0!  1 2
  when: capture{ within }capture
  then: captured@ ParameterStackUnderflow !=
        depth !2=
  test;

  test: within: checks if within fails gracefully on a stack with empty range.
  given sp0!
  when: capture{ 10 100 6 within }capture
  then: captured@ EmptyRange !=
        depth 0 !=
  test;

  test: and: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: and
  then: 46 !=
        depth 0 !=
  test;

  test: and: checks if and fails gracefully on an empty stack.
  given sp0!
  when: capture{ and }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: and: checks if and fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ and }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: or: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: and
  then: 4719 !=
        depth 0 !=
  test;

  test: or: checks if or fails gracefully on an empty stack.
  given sp0!
  when: capture{ or }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: or: checks if or fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ or }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: xor: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: and
  then: 4685 !=
        depth 0 !=
  test;

  test: xor: checks if xor fails gracefully on an empty stack.
  given sp0!
  when: capture{ xor }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: xor: checks if xor fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ xor }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: not: checks if the result is arithmetically correct.
  given sp0!  4711
  when: not
  then: -4712 !=
        depth 0 !=
  test;

  test: not: checks if not fails gracefully on an empty stack.
  given sp0!
  when: capture{ not }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: andn: checks if the result is arithmetically correct.
  given sp0!  42 4711
  when: andn
  then: 8 !=
        depth 0 !=
  test;

  test: andn: checks if andn fails gracefully on an empty stack.
  given sp0!
  when: capture{ andn }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: andn: checks if andn fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ andn }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  ( TODO tests for &&, ||, ^^ and ¬ )

  test: u<<: checks if the result is arithmetically correct.
  given sp0!  4711
  when: 5 u<<
  then: 150,742 !=
        depth 0 !=
  test;

  test: u<<: checks if u<< fails gracefully on an empty stack.
  given sp0!
  when: capture{ u<< }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u<<: checks if u<< fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u<< }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: u>>: checks if the result is arithmetically correct.
  given sp0!  4711
  when: 5 u>>
  then: 147 !=
        depth 0 !=
  test;

  test: u>>: checks if the result is arithmetically correct.
  given sp0!  -4711
  when: 5 u>>
  then: 7FF,FFFF,FFFF,FDC7H !=
        depth 0 !=
  test;

  test: u>>: checks if u>> fails gracefully on an empty stack.
  given sp0!
  when: capture{ u>> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u>>: checks if u>> fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ u>> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: <<: checks if the result is arithmetically correct.
  given sp0!  4711
  when: 5 <<
  then: 150,742 !=
        depth 0 !=
  test;

  test: <<: checks if << fails gracefully on an empty stack.
  given sp0!
  when: capture{ << }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: <<: checks if << fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ << }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: >>: checks if the result is arithmetically correct.
  given sp0!  4711
  when: 5 u>>
  then: 147 !=
        depth 0 !=
  test;

  test: >>: checks if the result is arithmetically correct.
  given sp0!  -4711
  when: 5 u>>
  then: -148 !=
        depth 0 !=
  test;

  test: >>: checks if >> fails gracefully on an empty stack.
  given sp0!
  when: capture{ >> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: >>: checks if >> fails gracefully on a stack with only one entry.
  given sp0!  42
  when: capture{ >> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: b@: checks if indeed a signed byte is fetched.
  given sp0!  666
  when: sp@ b@
  then: -102 !=
        drop depth 0 !=
  test;

  test: b@: checks if b@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ b@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: b@: checks if b@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 b@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: b@: checks if b@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 b@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: c@: checks if indeed an unsigned byte is fetched.
  given sp0!  666
  when: sp@ b@
  then: 154 !=
        drop depth 0 !=
  test;

  test: c@: checks if c@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ c@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c@: checks if c@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 c@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: c@: checks if c@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 c@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: s@: checks if indeed a signed word is fetched.
  given sp0!  123,456
  when: sp@ s@
  then: -7,616 !=
        drop depth 0 !=
  test;

  test: s@: checks if s@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ s@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: s@: checks if s@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 s@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: s@: checks if s@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 s@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: w@: checks if indeed an unsigned word is fetched.
  given sp0!  123,456
  when: sp@ w@
  then: 57,920 !=
        drop depth 0 !=
  test;

  test: w@: checks if w@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ w@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w@: checks if w@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 w@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: w@: checks if w@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 w@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: i@: checks if indeed a signed double-word is fetched.
  given sp0!  i#123,456,789,012
  when: sp@ i@
  then: i#-1,097,262,572 d!=
        ddrop depth 0 !=
  test;

  test: i@: checks if i@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ i@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: i@: checks if i@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 i@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: i@: checks if i@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 i@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: d@: checks if indeed an unsigned double-word is fetched.
  given sp0!  d#123,456,789,012
  when: sp@ d@
  then: d#3,197,704,724 d!=
        ddrop depth 0 !=
  test;

  test: d@: checks if d@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ d@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d@: checks if d@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 d@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: d@: checks if d@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 d@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: l@: checks if indeed a signed quad-word is fetched.
  given sp0!  l#$ABCD,EF01,2345,6789,ABCD
  when: sp@ l@
  then: l#-EF01,2345,6789,ABCE,H q!=
        qdrop depth 0 !=
  test;

  test: l@: checks if l@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ l@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: l@: checks if l@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 l@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: l@: checks if l@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 l@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: q@: checks if indeed an unsigned quad-word is fetched.
  given sp0!  q#$ABCD,EF01,2345,6789,ABCD
  when: sp@ d@
  then: q#EF01,2345,6789,ABCD,H q!=
        qdrop depth 0 !=
  test;

  test: q@: checks if q@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ q@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q@: checks if q@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 q@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: q@: checks if q@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 q@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: h@: checks if indeed a signed oct-word is fetched.
  given sp0!  h#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789,ABCD
  when: sp@ h@
  then: h#-10FE,DCBA,9876,5432,10FE,DCBA,9876,5433H o!=
        odrop depth 0 !=
  test;

  test: h@: checks if h@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ h@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: h@: checks if h@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 h@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: h@: checks if h@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 h@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: o@: checks if indeed an unsigned oct-word is fetched.
  given sp0!  o#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789,ABCD
  when: sp@ o@
  then: o#EF01,2345,6789,ABCD,EF01,2345,6789,ABCD,H o!=
        odrop depth 0 !=
  test;

  test: o@: checks if o@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ o@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: o@: checks if o@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 o@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: o@: checks if o@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 o@ }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: b@!: checks if the previous byte is returned and the new byte was stored.
  given sp0!  $ABCD
  when: 3 sp@ b@!
  then: -51 !=
        $AB03 !=
        depth 0 !=
  test;

  test: b@!: checks if b@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ b@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: b@!: checks if b@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ b@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: b@!: checks if b@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 b@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: b@!: checks if b@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 b@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: c@!: checks if the previous byte is returned and the new byte was stored.
  given sp0!  $ABCD
  when: 12 sp@ c@!
  then: 205 !=
        $AB0C !=
        depth 0 !=
  test;

  test: c@!: checks if c@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ c@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c@!: checks if c@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ c@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c@!: checks if c@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 c@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: c@!: checks if c@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 c@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: s@!: checks if the previous word is returned and the new word was stored.
  given sp0!  $6789ABCD
  when: -666 sp@ s@!
  then: -51 !=
        $6789FD66 !=
        depth 0 !=
  test;

  test: s@!: checks if s@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ s@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: s@!: checks if s@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ s@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: s@!: checks if s@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 s@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: s@!: checks if s@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 s@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: w@!: checks if the previous word is returned and the new word was stored.
  given sp0!  $6789ABCD
  when: -12 sp@ w@!
  then: 43,981 !=
        $6789FFEE !=
        depth 0 !=
  test;

  test: w@!: checks if w@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ w@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w@!: checks if w@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ w@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w@!: checks if w@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 w@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: w@!: checks if w@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 w@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: i@!: checks if the previous double-word is returned and the new double-word was stored.
  given sp0!  i#$6789,ABCD,EF01
  when: -1 sp@ i@!
  then: i#-1,412,567,295 d!=
        i#$6789,FFFF,FFFF d!=
        depth 0 !=
  test;

  test: i@!: checks if i@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ i@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: i@!: checks if i@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ i@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: i@!: checks if i@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 i@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: i@!: checks if i@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 i@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: d@!: checks if the previous double-word is returned and the new double-word was stored.
  given sp0!  d#$6789,ABCD,EF01
  when: 123456 sp@ d@!
  then: d#2,882,400,001 d!=
        d#$6789,0001,E240 d!=
        depth 0 !=
  test;

  test: d@!: checks if d@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ d@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d@!: checks if d@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ d@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d@!: checks if d@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 d@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: d@!: checks if d@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 d@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: l@!: checks if the previous quad-word is returned and the new quad-word was stored.
  given sp0!  l#$6789,ABCD,EF01,2345,6789
  when: l#-4711 sp@ l@!
  then: -l#5432,10FE,DCBA,9877H q!=
        l#$6789,FFFF,FFFF,FFFF,ED99 q!=
        depth 0 !=
  test;

  test: l@!: checks if l@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ l@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: l@!: checks if l@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ l@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: l@!: checks if l@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 l@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: l@!: checks if l@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 l@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

  test: q@!: checks if the previous quad-word is returned and the new quad-word was stored.
  given sp0!  q#$6789,ABCD,EF01,2345,6789
  when: l#-4711 sp@ q@!
  then: q#ABCD,EF01,2345,6789,H q!=
        q#$6789,FFFF,FFFF,FFFF,ED99 q!=
        depth 0 !=
  test;

  test: q@!: checks if q@! fails gracefully on an empty stack.
  given sp0!
  when: capture{ q@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q@!: checks if q@! fails gracefully on a stack with only one entry.
  given sp0!  666
  when: capture{ q@! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q@!: checks if q@! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 q@! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 1 !=
  test;

  test: q@!: checks if q@! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 q@! }capture
  then: captured@ NullPointer !=
        depth 1 !=
  test;

( TODO tests for v@! and o@! )

  test: b@++: checks if the correct signed byte is returned and the address is incremented.
  given sp0!  666
  when: sp@ b@++
  then: -102 !=
        sp@ cell+ 1 + !=
        depth 0 !=
  test;

  test: b@++: checks if b@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ b@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: b@++: checks if b@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 b@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: b@++: checks if b@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 b@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: c@++: checks if the correct unsigned byte is returned and the address is incremented.
  given sp0!  666
  when: sp@ c@++
  then: 154 !=
        sp@ cell+ 1 + !=
        depth 0 !=
  test;

  test: c@++: checks if c@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ c@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c@++: checks if c@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 c@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c@++: checks if c@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 c@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: s@++: checks if the correct signed word is returned and the address is incremented.
  given sp0!  3,333,333
  when: sp@ s@++
  then: -9003 !=
        sp@ cell+ 2 + !=
        depth 0 !=
  test;

  test: s@++: checks if s@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ s@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: s@++: checks if s@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 s@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: s@++: checks if s@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 s@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: w@++: checks if the correct unsigned word is returned and the address is incremented.
  given sp0!  3,333,333
  when: sp@ w@++
  then: 56533 !=
        sp@ cell+ 2 + !=
        depth 0 !=
  test;

  test: w@++: checks if w@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ w@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w@++: checks if w@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 w@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w@++: checks if w@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 w@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: i@++: checks if the correct signed double-word is returned and the address is incremented.
  given sp0!  i#$6789,ABCD,EF01
  when: sp@ i@++
  then: i#-1,412,567,295 d!=
        sp@ cell+ 4 + !=
        depth 0 !=
  test;

  test: i@++: checks if i@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ i@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: i@++: checks if i@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 i@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: i@++: checks if i@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 i@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: d@++: checks if the correct unsigned double-word is returned and the address is incremented.
  given sp0!  d#$6789,ABCD,EF01
  when: sp@ d@++
  then: d#2,882,400,001 d!=
        sp@ cell+ 4 + !=
        depth 0 !=
  test;

  test: d@++: checks if d@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ d@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d@++: checks if d@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 d@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: d@++: checks if d@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 d@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: l@++: checks if the correct signed quad-word is returned and the address is incremented.
  given sp0!  l#$6789,ABCD,EF01,2345,6789
  when: sp@ l@++
  then: -l#5432,10FE,DCBA,9877H q!=
        sp@ cell+ 8 + !=
        depth 0 !=
  test;

  test: l@++: checks if l@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ l@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: l@++: checks if l@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 l@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: l@++: checks if l@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 l@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: q@++: checks if the correct unsigned quad-word is returned and the address is incremented.
  given sp0!  q#$6789,ABCD,EF01,2345,6789
  when: sp@ q@++
  then: q#ABCD,EF01,2345,6789H q!=
        sp@ cell+ 8 + !=
        depth 0 !=
  test;

  test: q@++: checks if q@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ q@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q@++: checks if q@++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 q@++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: q@++: checks if q@++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 q@++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  ( TODO tests for v@++ and o@++ )

  test: −−b@: checks if the correct signed byte is returned and the address is decremented.
  given sp0!  −4711
  when: sp@ 1 + −−b@
  then: -103 !=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−b@: checks if −−b@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−b@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−b@: checks if −−b@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−b@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−b@: checks if −−b@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−b@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−c@: checks if the correct unsigned byte is returned and the address is decremented.
  given sp0!  -4711
  when: sp@ 1 + −−c@
  then: 153 !=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−c@: checks if −−c@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−c@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−c@: checks if −−b@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−c@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−c@: checks if −−c@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−c@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−s@: checks if the correct signed word is returned and the address is decremented.
  given sp0!  123,456,789
  when: sp@ 2 + −−s@
  then: -13,035 !=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−s@: checks if −−s@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−s@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−s@: checks if −−s@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−s@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−s@: checks if −−s@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−s@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−w@: checks if the correct unsigned word is returned and the address is decremented.
  given sp0!  123,456,789
  when: sp@ 2 + −−w@
  then: 52,501 !=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−w@: checks if −−w@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−w@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−w@: checks if −−w@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−w@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−w@: checks if −−w@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−w@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−i@: checks if the correct signed double-word is returned and the address is decremented.
  given sp0!  i#123,456,789,012,345
  when: sp@ 4 + −−i@
  then: i#-2,045,911,175 d!=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−i@: checks if −−i@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−i@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−i@: checks if −−i@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−i@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−i@: checks if −−i@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−i@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−d@: checks if the correct unsigned double-word is returned and the address is decremented.
  given sp0!  d#123,456,789,012,345
  when: sp@ 4 + −−d@
  then: d#2,249,056,121 d!=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−d@: checks if −−d@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−d@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−d@: checks if −−d@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−d@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−d@: checks if −−d@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−d@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−l@: checks if the correct signed quad-word is returned and the address is decremented.
  given sp0!  l#$6789,ABCD,EF01,2345,6789
  when: sp@ 8 + −−l@
  then: l#-6,066,930,334,832,433,271 q!=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−l@: checks if −−l@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−l@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−l@: checks if −−l@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−l@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−l@: checks if −−l@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−l@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−q@: checks if the correct unsigned quad-word is returned and the address is decremented.
  given sp0!  q#$6789,ABCD,EF01,2345,6789
  when: sp@ 8 + −−q@
  then: q#ABCD,EF01,2345,6789H q!=
        sp@ cell+ !=
        depth 0 !=
  test;

  test: −−q@: checks if −−q@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−q@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−q@: checks if −−q@ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −−q@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−q@: checks if −−q@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−q@ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  ( TODO tests for --v@ and --o@ )

  test: c!: checks if byte c is in fact stored at address a.
  given sp0!  -1
  when: sp@ 42 swap c!
  then: -214 !=
        depth 0 !=
  test;

  test: c!: checks if only byte c is stored at address a.
  given sp0!  0
  when: sp@ -42 swap c!
  then: 214 !=
        depth 0 !=
  test;

  test: c!: checks if c! fails gracefully on an empty stack.
  given sp0!
  when: capture{ c! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c!: checks if c! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 c! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c!: checks if c! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 c! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: w!: checks if word w is in fact stored at address a.
  given sp0!  -1
  when: sp@ 4711 swap w!
  then: -60,825 !=
        depth 0 !=
  test;

  test: w!: checks if only word w is stored at address a.
  given sp0!  0
  when: sp@ -42 swap w!
  then: 65,494 !=
        depth 0 !=
  test;

  test: w!: checks if w! fails gracefully on an empty stack.
  given sp0!
  when: capture{ w! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w!: checks if w! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 w! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w!: checks if w! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 w! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: d!: checks if double-word d is in fact stored at address a.
  given sp0!  i#-1
  when: sp@ d#2345678901 swap d!
  then: i#-1,949,288,395 d!=
        depth 0 !=
  test;

  test: d!: checks if only double-word d is stored at address a.
  given sp0!  0
  when: sp@ -42 swap d!
  then: d#4,294,967,254 d!=
        depth 0 !=
  test;

  test: d!: checks if d! fails gracefully on an empty stack.
  given sp0!
  when: capture{ d! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d!: checks if d! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 d! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: d!: checks if d! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 d! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: q!: checks if quad-word q is in fact stored at address a.
  given sp0!  l#-1
  when: sp@ q#$ABCD,EF01,2345,6789 swap q!
  then: l#-1949288395 q!=
        depth 0 !=
  test;

  test: q!: checks if only quad-word q is stored at address a.
  given sp0!  q#0
  when: sp@ l#-42 swap q!
  then: q# $FFFF,FFFF,FFFF,FFD6 q!=
        depth 0 !=
  test;

  test: q!: checks if q! fails gracefully on an empty stack.
  given sp0!
  when: capture{ q! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q!: checks if q! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 q! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: q!: checks if q! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 q! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: o!: checks if oct-word o is in fact stored at address a.
  given sp0!  -1
  when: sp@ o#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789 swap o!
  then: o#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789 o!=
        depth 0 !=
  test;

  test: o!: checks if only oct-word o is stored at address a.
  given sp0!  o#0
  when: sp@ h#-42 swap q!
  then: o#$FFFF,FFFF,FFFF,FFFF,FFFF,FFFF,FFFF,FFD6 o!=
        depth 0 !=
  test;

  test: o!: checks if o! fails gracefully on an empty stack.
  given sp0!
  when: capture{ o! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: o!: checks if o! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 o! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: o!: checks if o! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 o! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: #!: checks if byte is stored at address a when #=1.
  given sp0!  -1
  when: sp@ 4711 swap 1 #!
  then: -153 !=
        depth 0 !=
  test;

  test: #!: checks if word is stored at address a when #=2.
  given sp0!  -1
  when: sp@ 4711 swap 2 #!
  then: -60,825 !=
        depth 0 !=
  test;

  test: #!: checks if 3 bytes are stored at address a when #=3.
  given sp0!  -1
  when: sp@ 4711 swap 3 #!
  then: -16,772,505 !=
        depth 0 !=
  test;

  test: #!: checks if double-word is stored at address a when #=4.
  given sp0!  l#-1
  when: sp@ d#123,456,798,012,345 swap 4 #!
  then: l#-2,045,911,175 !=
        depth 0 !=
  test;

  test: #!: checks if nothing is stored at address a when #=0.
  given sp0!  -1
  when: sp@ q#123,456,798,012,345 swap 0 #!
  then: -1 !=
        depth 0 !=
  test;

  test: #!: checks if nothing is stored at address a when #<0.
  given sp0!  -1
  when: sp@ q#123,456,798,012,345 swap -4 #!
  then: -1 !=
        depth 0 !=
  test;

  test: #!: checks if #! fails gracefully on an empty stack.
  given sp0!
  when: capture{ #! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: #!: checks if #! fails gracefully on a stack with only 1 entry.
  given sp0!  1
  when: capture{ #! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: #!: checks if #! fails gracefully on a stack with only 2 entries.
  given sp0!  sp@ 1
  when: capture{ #! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: #!: checks if #! fails gracefully with a bad address.
  given sp0!
  when: capture{ 0 -1 1 #! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: #!: checks if #! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 0 1 #! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: c!++: checks if byte c is stored at address a, and address is incremented.
  given sp0!  -1
  when: sp@ 42 c!++
  then: sp@ cell+ 1 + !=
        -214 !=
        depth 0 !=
  test;

  test: c!++: checks if only byte c is stored at address a.
  given sp0!  0
  when: sp@ -42 swap c!++
  then: sp@ cell+ 1 + !=
        214 !=
        depth 0 !=
  test;

  test: c!++: checks if c!++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ c!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c!++: checks if c!++ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ c!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c!++: checks if c!++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 c!++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c!++: checks if c!++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 c!++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: w!++: checks if word w is stored at address a, and address is incremented.
  given sp0!  -1
  when: sp@ 4711 w!++
  then: sp@ cell+ 2 + !=
        -60,825 !=
        depth 0 !=
  test;

  test: w!++: checks if only word w is stored at address a.
  given sp0!  0
  when: sp@ -42 swap w!++
  then: sp@ cell+ 2 + !=
        65,494 !=
        depth 0 !=
  test;

  test: w!++: checks if w!++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ w!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w!++: checks if w!++ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ w!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w!++: checks if w!++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 w!++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w!++: checks if w!++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 w!++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: d!++: checks if double-word d is stored at address a, and address is incremented.
  given sp0!  d#-1
  when: sp@ d#2,345,678,901 d!++
  then: sp@ cell+ 4 + !=
        i#-1,949,288,395 d!=
        depth 0 !=
  test;

  test: d!++: checks if only double-word d is stored at address a.
  given sp0!  d#0
  when: sp@ i#-42 swap d!++
  then: sp@ cell+ 4 + !=
        d#4,294,967,254 d!=
        depth 0 !=
  test;

  test: d!++: checks if d!++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ d!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d!++: checks if d!++ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ d!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d!++: checks if d!++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 d!++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: d!++: checks if d!++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 d!++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: q!++: checks if quad-word q is stored at address a, and address is incremented.
  given sp0!  l#-1
  when: sp@ q#$ABCD,EF01,2345,6789 q!++
  then: sp@ cell+ 8 + !=
        l#-1,949,288,395 q!=
        depth 0 !=
  test;

  test: q!++: checks if only quad-word q is stored at address a.
  given sp0!  q#0
  when: sp@ l#-42 swap d!++
  then: sp@ cell+ 8 + !=
        q#$FFFF,FFFF,FFFF,FFD6 q!=
        depth 0 !=
  test;

  test: q!++: checks if q!++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ q!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q!++: checks if q!++ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ q!++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q!++: checks if q!++ fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 q!++ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: q!++: checks if q!++ fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 q!++ }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  ( TODO tests for o!++ )

  test: −−c!: checks if byte c is stored at address a−1, and address is decremented.
  given sp0!  -1
  when: sp@ 42 −−c!
  then: sp@ cell+ 1 − !=
        -54529 !=
        depth 0 !=
  test;

  test: −−c!: checks if only byte c is stored at address a.
  given sp0!  0
  when: sp@ -42 swap c!++
  then: sp@ cell+ 1 − !=
        54784 !=
        depth 0 !=
  test;

  test: −−c!: checks if −−c! fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−c! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−c!: checks if −−c! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ −−c! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−c!: checks if −−c! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 −−c! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−c!: checks if −−c! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−c! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−w!: checks if word w is stored at address a, and address is decremented.
  given sp0!  -1
  when: sp@ 2 + 4711 −−w!
  then: sp@ cell+ !=
        -60,825 !=
        depth 0 !=
  test;

  test: −−w!: checks if only word w is stored at address a.
  given sp0!  0
  when: sp@ 2 + -42 swap −−w!
  then: sp@ cell+ !=
        65,494 !=
        depth 0 !=
  test;

  test: −−w!: checks if −−w! fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−w! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−w!: checks if −−w! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ −−w! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−w!: checks if −−w! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 −−w! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−w!: checks if −−w! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−w! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−d!: checks if double-word d is stored at address a, and address is decremented.
  given sp0!  i#-1
  when: sp@ d#2,345,678,901 −−d!
  then: sp@ 4 + cell+ !=
        i#-1,949,288,395 d!=
        depth 0 !=
  test;

  test: −−d!: checks if only double-word d is stored at address a.
  given sp0!  0
  when: sp@ 4 + -42 swap −−d!
  then: sp@ cell+ !=
        d#4,294,967,254 d!=
        depth 0 !=
  test;

  test: −−d!: checks if −−d! fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−d! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−d!: checks if −−d! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ −−d! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−d!: checks if −−d! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 −−d! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−d!: checks if −−d! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−d! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: −−q!: checks if quad-word q is stored at address a, and address is decremented.
  given sp0!  l#-1
  when: sp@ 8 + q#$ABCD,EF01,2345,6789 −−q!
  then: sp@ cell+ !=
        l#-1,949,288,395 q!=
        depth 0 !=
  test;

  test: −−q!: checks if only quad-word q is stored at address a.
  given sp0!  q#0
  when: sp@ 8 + l#-42 swap −−d!
  then: sp@ cell+ !=
        q#$FFFF,FFFF,FFFF,FFD6 q!=
        depth 0 !=
  test;

  test: −−q!: checks if −−q! fails gracefully on an empty stack.
  given sp0!
  when: capture{ −−q! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−q!: checks if −−q! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ −−q! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: −−q!: checks if −−q! fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 0 −−q! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: −−q!: checks if −−q! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −−q! }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  ( TODO test for --o! )

  test: c+!: checks if c is added to byte at address a.
  given sp0!  -1
  when: sp@ 8 swap c+!
  then: -249 !=
        depth 0 !=
  test;

  test: c+!: checks if c+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ c+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c+!: checks if c+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ c+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: c+!: checks if c+! fails gracefully with a bad address.
  given sp0!
  when: capture{ 0 -1 c+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c+!: checks if c+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 0 c+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w+!: checks if w is added to word at address a.
  given sp0!  -1
  when: sp@ 4711 swap w+!
  then: -60,825 !=
        depth 0 !=
  test;

  test: w+!: checks if w+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ w+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w+!: checks if w+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ w+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: w+!: checks if w+! fails gracefully with a bad address.
  given sp0!
  when: capture{ 0 -1 w+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w+!: checks if w+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 0 w+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: d+!: checks if d is added to double-word at address a.
  given sp0!  i#-1
  when: sp@ >r d#123,456,789,012 r> d+!
  then: i#-4,294,967,297 d!=
        depth 0 !=
  test;

  test: d+!: checks if d+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ d+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d+!: checks if d+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ d+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: d+!: checks if d+! fails gracefully with a bad address.
  given sp0!
  when: capture{ d#0 -1 d+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: d+!: checks if d+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ d#0 0 d+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: q+!: checks if q is added to quad-word at address a.
  given sp0!  l#-1
  when: sp@ >r q#123,456,789,012 r> q+!
  then: l#-4,294,967,297 !=
        depth 0 !=
  test;

  test: q+!: checks if q+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ q+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q+!: checks if q+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ q+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: q+!: checks if q+! fails gracefully with a bad address.
  given sp0!
  when: capture{ q#0 -1 q+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: q+!: checks if q+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ q#0 0 q+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: o+!: checks if o is added to oct-word at address a.
  given sp0!  h#-1
  when: sp@ >r o#123,456,789,012,345,678,901,234 r> o+!
  then: o#123,456,789,012,345,678,901,233 o!=
        depth 0 !=
  test;

  test: o+!: checks if o+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ o+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: o+!: checks if o+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ o+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: o+!: checks if o+! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 o+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: o+!: checks if o+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 o+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c−!: checks if c is subtracted from byte at address a.
  given sp0!  -1
  when: sp@ −8 swap c−!
  then: -249 !=
        depth 0 !=
  test;

  test: c−!: checks if c−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ c−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c−!: checks if c−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ c−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: c−!: checks if c−! fails gracefully with a bad address.
  given sp0!
  when: capture{ 0 -1 c−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c−!: checks if c−! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 0 c−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w−!: checks if w is subtracted from word at address a.
  given sp0!  -1
  when: sp@ −4711 swap w−!
  then: -60,825 !=
        depth 0 !=
  test;

  test: w−!: checks if w−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ w−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: w−!: checks if w−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ w−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: w−!: checks if w−! fails gracefully with a bad address.
  given sp0!
  when: capture{ 0 -1 w−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: w−!: checks if w−! fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 0 w−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: d−!: checks if d is subtracted from double-word at address a.
  given sp0!  i#-1
  when: sp@ >r i#−123,456,789,012 r> d−!
  then: i#-4,294,967,297 d!=
        depth 0 !=
  test;

  test: d−!: checks if d−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ d−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: d−!: checks if d−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ d−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: d−!: checks if d−! fails gracefully with a bad address.
  given sp0!
  when: capture{ d#0 -1 d−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: q−!: checks if q is subtracted from quad-word at address a.
  given sp0!  l#-1
  when: sp@ >r l#−123,456,789,012 r> q−!
  then: l#-4,294,967,297 !=
        depth 0 !=
  test;

  test: q−!: checks if q−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ q−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: q−!: checks if q−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ q−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: o−!: checks if o is subtracted from oct-word at address a.
  given sp0!  h#-1
  when: sp@ >r h#-123,456,789,012,345,678,901,234 r> o−!
  then: o#123,456,789,012,345,678,901,233 o!=
        depth 0 !=
  test;

  test: o−!: checks if o−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ o−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: o−!: checks if o−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ o−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: o−!: checks if o−! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 o−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: o−!: checks if o−! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 o−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  ( TODO tests for bit?, bit+, bit−, bit×, bit?+, bit?−, bit?×, bita?+, bita?−, bita?× )

  test: bit@: checks if bit 0 is set.
  given sp0!  1
  when: sp@ 0 bit@
  then: true !=
        drop  depth 0 !=
  test;

  test: bit@: checks if bit 8 is not set.
  given sp0!  1
  when: sp@ 8 bit@
  then: false !=
        drop  depth 0 !=
  test;

  test: bit@: checks if bit 194 is set.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bit@
  then: true !=
        4qdrop  depth 0 !=
  test;

  test: bit@: checks if bit 200 is set.
  given sp0!  q#256  q#0  q#0  q#0
  when: sp@ 200 bit@
  then: false !=
        4qdrop  depth 0 !=
  test;

  test: bit@: checks if bit@ fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit@: checks if bit@ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit@ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit@: checks if bit@ fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@: checks if bit@ fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit@ }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit+!: checks if bit 0 is set.
  given sp0!  0
  when: sp@ 0 bit+!
  then: 1 !=
        depth 0 !=
  test;

  test: bit+!: checks if bit 8 is set.
  given sp0!  0
  when: sp@ 8 bit+!
  then: 256 !=
        depth 0 !=
  test;

  test: bit+!: checks if bit 194 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 194 bit+!
  then: 3 qpick q#2 q!=
        4qdrop  depth 0 !=
  test;

  test: bit+!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bit+!
  then: 3 qpick q#256 q!=
        4qdrop  depth 0 !=
  test;

  test: bit+!: checks if bit+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit+!: checks if bit+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit+!: checks if bit+! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit+!: checks if bit+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit−!: checks if bit 0 is clear.
  given sp0!  −1
  when: sp@ 0 bit−!
  then: −2 !=
        depth 0 !=
  test;

  test: bit−!: checks if bit 8 is clear.
  given sp0!  256
  when: sp@ 8 bit−!
  then: 0 !=
        depth 0 !=
  test;

  test: bit−!: checks if bit 194 is set.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bit−!
  then: 3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit−!: checks if bit 200 is set.
  given sp0!  q#256  q#0  q#0  q#0
  when: sp@ 200 bit−!
  then: 3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit−!: checks if bit−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit−!: checks if bit−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit−!: checks if bit−! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit−!: checks if bit−! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit×!: checks if bit 0 is clear.
  given sp0!  −1
  when: sp@ 0 bit×!
  then: −2 !=
        depth 0 !=
  test;

  test: bit×!: checks if bit 0 is set.
  given sp0!  0
  when: sp@ 0 bit×!
  then: 1 !=
        depth 0 !=
  test;

  test: bit×!: checks if bit 194 is clear.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bit×!
  then: 3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit×!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bit×!
  then: 3 qpick q#256 q!=
        4qdrop  depth 0 !=
  test;

  test: bit×!: checks if bit×! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit×! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit×!: checks if bit×! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit×! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit×!: checks if bit×! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit×! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit×!: checks if bit×! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit×! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@+!: checks if bit 0 is set.
  given sp0!  0
  when: sp@ 0 bit@+!
  then: false !=
        1 !=
        depth 0 !=
  test;

  test: bit@+!: checks if bit 8 is set.
  given sp0!  256
  when: sp@ 8 bit@+!
  then: true !=
        256 !=
        depth 0 !=
  test;

  test: bit@+!: checks if bit 194 is set.
  given sp0!  q#2  q#0  q#0  q#0
  when: sp@ 194 bit@+!
  then: true !=
        3 qpick q#2 q!=
        4qdrop  depth 0 !=
  test;

  test: bit@+!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bit@+!
  then: false !=
        3 qpick q#256 q!=
        4qdrop  depth 0 !=
  test;

  test: bit@+!: checks if bit@+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit@+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit@+!: checks if bit@+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit@+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit@+!: checks if bit@+! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit@+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@+!: checks if bit@+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit@+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@−!: checks if bit 0 is clear.
  given sp0!  −1
  when: sp@ 0 bit@−!
  then: true !=
        −2 !=
        depth 0 !=
  test;

  test: bit@−!: checks if bit 8 is clear.
  given sp0!  0
  when: sp@ 8 bit@−!
  then: false !=
        0 !=
        depth 0 !=
  test;

  test: bit@−!: checks if bit 194 is set.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bit@−!
  then: true !=
        3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit@−!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bit@−!
  then: false !=
        3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit@−!: checks if bit@−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit@−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit@−!: checks if bit@−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit@−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit@−!: checks if bit@−! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit@−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@−!: checks if bit@−! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit@−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@×!: checks if bit 0 is clear.
  given sp0!  −1
  when: sp@ 0 bit@×!
  then: true !=
        −2 !=
        depth 0 !=
  test;

  test: bit@×!: checks if bit 0 is set.
  given sp0!  0
  when: sp@ 0 bit@×!
  then: false !=
        1 !=
        depth 0 !=
  test;

  test: bit@×!: checks if bit 194 is clear.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bit@×!
  then: true !=
        3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit×!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bit@×!
  then: 3 qpick q#256 q!=
        4qdrop  depth 0 !=
  test;

  test: bit@×!: checks if bit@×! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bit@×! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bit@×!: checks if bit@×! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bit@×! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bit@×!: checks if bit@×! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bit@×! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bit@×!: checks if bit@×! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bit@×! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bita@+!: checks if bit 0 is set.
  given sp0!  0
  when: sp@ 0 bita@+!
  then: false !=
        1 !=
        depth 0 !=
  test;

  test: bita@+!: checks if bit 8 is set.
  given sp0!  256
  when: sp@ 8 bita@+!
  then: true !=
        256 !=
        depth 0 !=
  test;

  test: bita@+!: checks if bit 194 is set.
  given sp0!  q#2  q#0  q#0  q#0
  when: sp@ 194 bita@+!
  then: true !=
        3 qpick q#2 q!=
        4qdrop  depth 0 !=
  test;

  test: bita@+!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bita@+!
  then: false !=
        3 qpick q#256 q!=
        4qdrop  depth 0 !=
  test;

  test: bita@+!: checks if bita@+! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bita@+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bita@+!: checks if bita@+! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bita@+! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bita@+!: checks if bita@+! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bita@+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bita@+!: checks if bita@+! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bita@+! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bita@−!: checks if bit 0 is clear.
  given sp0!  −1
  when: sp@ 0 bita@−!
  then: true !=
        −2 !=
        depth 0 !=
  test;

  test: bita@−!: checks if bit 8 is clear.
  given sp0!  0
  when: sp@ 8 bita@−!
  then: false !=
        0 !=
        depth 0 !=
  test;

  test: bita@−!: checks if bit 194 is set.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bita@−!
  then: true !=
        3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bita@−!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bita@−!
  then: false !=
        3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bita@−!: checks if bita@−! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bita@−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bita@−!: checks if bita@−! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bita@−! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bita@−!: checks if bita@−! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bita@−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bita@−!: checks if bita@−! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bita@−! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bita@×!: checks if bit 0 is clear.
  given sp0!  −1
  when: sp@ 0 bita@×!
  then: true !=
        −2 !=
        depth 0 !=
  test;

  test: bita@×!: checks if bit 0 is set.
  given sp0!  0
  when: sp@ 0 bita@×!
  then: false !=
        1 !=
        depth 0 !=
  test;

  test: bita@×!: checks if bit 194 is clear.
  given sp0!  q#4  q#0  q#0  q#0
  when: sp@ 194 bita@×!
  then: true !=
        3 qpick q#0 q!=
        4qdrop  depth 0 !=
  test;

  test: bit×!: checks if bit 200 is set.
  given sp0!  q#0  q#0  q#0  q#0
  when: sp@ 200 bita@×!
  then: 3 qpick q#256 q!=
        4qdrop  depth 0 !=
  test;

  test: bita@×!: checks if bita@×! fails gracefully on an empty stack.
  given sp0!
  when: capture{ bita@×! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: bita@×!: checks if bita@×! fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ sp@ bita@×! }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: bita@×!: checks if bita@×! fails gracefully with a bad address.
  given sp0!
  when: capture{ o#0 -1 bita@×! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: bita@×!: checks if bita@×! fails gracefully with a null pointer.
  given sp0!
  when: capture{ o#0 0 bita@×! }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: cfill: checks if buffer is partially filled with the byte.
  given sp0!  create cfillbfr  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  −1 c,
  when: cfillbfr 10 20H cfill
  then: cfillbfr 10 0 do  c@++ 20H !=  loop  10 0 do  c@++ 0 !=  loop
        b@ -1 !=
        depth 0 !=
  test;

  test: cfill: checks if cfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ cfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: cfill: checks if cfill fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 cfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: cfill: checks if cfill fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 cfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: cfill: checks if cfill fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 cfill }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: cfill: checks if cfill fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 cfill }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: wfill: checks if buffer is partially filled with the word.
  given sp0!  create wfillbfr  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  −1 w,
  when: wfillbfr 10 4711 wfill
  then: wfillbfr 10 0 do  w@++ 4711 !=  loop  10 0 do  w@++ 0 !=  loop
        s@ −1 !=
        depth 0 !=
  test;

  test: wfill: checks if wfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ wfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: wfill: checks if wfill fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 wfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: wfill: checks if wfill fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 wfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: wfill: checks if wfill fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 wfill }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: wfill: checks if wfill fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 wfill }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: dfill: checks if buffer is partially filled with the double-word.
  given sp0!  create dfillbfr  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,
  when: dfillbfr 10 d#123,456,789 dfill
  then: dfillbfr 10 0 do  d@++ d#123,456,789 !=  loop  10 0 do  d@++ 0 !=  loop
        i@ −1 !=
        depth 0 !=
  test;

  test: dfill: checks if dfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ dfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: dfill: checks if dfill fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 dfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: dfill: checks if dfill fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 dfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: dfill: checks if dfill fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 dfill }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: dfill: checks if dfill fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 dfill }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: qfill: checks if buffer is partially filled with the quad-word.
  given sp0!  create qfillbfr  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,
  when: qfillbfr 10 q#123,456,789,012,345 qfill
  then: qfillbfr 10 0 do  q@++ q#123,456,789,012,345 !=  loop  10 0 do  q@++ 0 !=  loop
        l@ −1 !=
        depth 0 !=
  test;

  test: qfill: checks if qfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ qfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: qfill: checks if qfill fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 qfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: qfill: checks if qfill fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 qfill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: qfill: checks if qfill fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 qfill }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: qfill: checks if qfill fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 qfill }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: ofill: checks if buffer is partially filled with the oct-word.
  given sp0!  create ofillbfr  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,
  when: ofillbfr 10 o#123,456,789,012,345,678,901,234 ofill
  then: ofillbfr 10 0 do  o@++ q#123,456,789,012,345 !=  loop  10 0 do  o@++ 0 !=  loop
        h@ −1 !=
        depth 0 !=
  test;

  test: ofill: checks if ofill fails gracefully on an empty stack.
  given sp0!
  when: capture{ ofill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ofill: checks if ofill fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 ofill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: ofill: checks if ofill fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 ofill }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: ofill: checks if ofill fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 ofill }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: ofill: checks if ofill fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 ofill }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: cfind: checks if the byte is found in the buffer.
  given sp0!  create cfindbfr  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0AH c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  −1 c,
  when: cfindbfr 10 0AH cfind
  then: 9 !=
        depth 0 !=
  test;

  test: cfind: checks if the byte is not found in the buffer.
  given sp0!
  when: cfindbfr 10 0BH cfind
  then: 0 !=
        depth 0 !=
  test;

  test: cfind: checks if cfind fails gracefully on an empty stack.
  given sp0!
  when: capture{ cfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: cfind: checks if cfind fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 cfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: cfind: checks if cfind fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 cfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: cfind: checks if cfind fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 cfind }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: cfind: checks if cfind fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 cfind }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: wfind: checks if the word is found in the buffer.
  given sp0!  create wfindbfr  0 w,  0 w,  4711 w,  0 w,  0 w,  0 w,  0 w,  0 w,  4711 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  −1 w,
  when: cfindbfr 10 4711 wfind
  then: 3 !=
        depth 0 !=
  test;

  test: wfind: checks if the word is not found in the buffer.
  given sp0!
  when: wfindbfr 10 4722 wfind
  then: 0 !=
        depth 0 !=
  test;

  test: wfind: checks if wfind fails gracefully on an empty stack.
  given sp0!
  when: capture{ wfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: wfind: checks if wfind fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 wfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: wfind: checks if wfind fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 wfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: wfind: checks if wfind fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 wfind }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: wfind: checks if wfind fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 wfind }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: dfind: checks if the double-word is found in the buffer.
  given sp0!  create dfindbfr  0 d,  0 d,  4711 d,  0 d,  0 d,  0 d,  0 d,  0 d,  d#123,456,789,012 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  −1 d,
  when: dfindbfr 10 d#123,456,789,012 dfind
  then: 9 !=
        depth 0 !=
  test;

  test: dfind: checks if the double-word is not found in the buffer.
  given sp0!
  when: dfindbfr 10 711 dfind
  then: 0 !=
        depth 0 !=
  test;

  test: dfind: checks if dfind fails gracefully on an empty stack.
  given sp0!
  when: capture{ dfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: dfind: checks if dfind fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 dfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: dfind: checks if dfind fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 dfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: dfind: checks if dfind fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 dfind }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: dfind: checks if dfind fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 dfind }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: qfind: checks if the quad-word is found in the buffer.
  given sp0!  create qfindbfr  0 q,  0 q,  4711 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  d#123,456,789,012 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  −1 q,
  when: qfindbfr 10 d#123,456,789,012 qfind
  then: 10 !=
        depth 0 !=
  test;

  test: qfind: checks if the quad-word is not found in the buffer.
  given sp0!
  when: qfindbfr 10 711 qfind
  then: 0 !=
        depth 0 !=
  test;

  test: qfind: checks if qfind fails gracefully on an empty stack.
  given sp0!
  when: capture{ qfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: qfind: checks if qfind fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 qfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: qfind: checks if qfind fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 qfind }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: qfind: checks if qfind fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 qfind }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: qfind: checks if qfind fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 qfind }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  ( TODO test for ofind )

  test: cmove: checks if buffer is partially copied.
  given sp0!  create cmovetgt  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  −1 c,
        create cmovesrc  1 c,  2 c,  3 c,  4 c,  5 c,  6 c,  7 c,  8 c,  9 c,  10 c,  11 c,  12 c,  13 c,  14 c,  15 c,  16 c,  17 c,  18 c,  19 c,  20 c,  −1 c,
  when: cmovesrc cmovetgt 10 cmove
  then: cmovetgt cmovesrc 10 0 do  swap c@++ rot c@++ rot !=  loop  drop  10 0 do  c@++ 0 !=  loop
        b@ -1 !=
        depth 0 !=
  test;

  test: cmove: checks if reverse move is applied when danger of overriding.
  given sp0!
  when: cmovesrc dup 1 + 10 cmove
  then: 12 10 9 8 7 6 5 4 3 2 1 1 cmovesrc 12 for  c@++ rot !=  next  drop
        depth 0 !=
  test;

  test: cmove: checks if cfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ cmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: cmove: checks if cmove fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 cmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: cmove: checks if cmove fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 1 $20 cmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: cmove: checks if cmove fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −1 $20 cmove }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: cmove: checks if cmove fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 −1 $20 cmove }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: wmove: checks if buffer is partially copied.
  given sp0!  create wmovetgt  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  −1 w,
        create wmovesrc  1 w,  2 w,  3 w,  4 w,  5 w,  6 w,  7 w,  8 w,  9 w,  10 w,  11 w,  12 w,  13 w,  14 w,  15 w,  16 w,  17 w,  18 w,  19 w,  20 w,  −1 w,
  when: wmovesrc wmovetgt 10 wmove
  then: wmovetgt wmovesrc 10 0 do  swap w@++ rot w@++ rot !=  loop  drop  10 0 do  w@++ 0 !=  loop
        s@ -1 !=
        depth 0 !=
  test;

  test: wmove: checks if reverse move is applied when danger of overriding.
  given sp0!
  when: wmovesrc dup 2 + 10 wmove
  then: 12 10 9 8 7 6 5 4 3 2 1 1 wmovesrc 12 for  w@++ rot !=  next  drop
        depth 0 !=
  test;

  test: wmove: checks if cfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ wmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: wmove: checks if wmove fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 wmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: wmove: checks if wmove fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 1 $20 wmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: wmove: checks if wmove fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 −1 $20 wmove }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: wmove: checks if wmove fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 -1 $20 wmove }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: dmove: checks if buffer is partially copied.
  given sp0!  create dmovetgt  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  i#−1 d,
        create wmovesrc  d#1 d,  d#2 d,  d#3 d,  d#4 d,  d#5 d,  d#6 d,  d#7 d,  d#8 d,  d#9 d,  d#10 d,  d#11 d,  d#12 d,  d#13 d,  d#14 d,  d#15 d,  d#16 d,  d#17 d,  d#18 d,  d#19 d,  d#20 d,  i#−1 d,
  when: dmovesrc dmovetgt 10 dmove
  then: dmovetgt dmovesrc 10 0 do  swap d@++ rot d@++ rot d!=  loop  drop  10 0 do  d@++ d#0 d!=  loop
        i@ i#-1 !=
        depth 0 !=
  test;

  test: dmove: checks if reverse move is applied when danger of overriding.
  given sp0!
  when: dmovesrc dup d# + 10 dmove
  then: d#12 d#10 d#9 d#8 d#7 d#6 d#5 d#4 d#3 d#2 d#1 d#1 dmovesrc 12 for  d@++ rot d!=  next  drop
        depth 0 !=
  test;

  test: dmove: checks if cfill fails gracefully on an empty stack.
  given sp0!
  when: capture{ dmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: dmove: checks if dmove fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 dmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: dmove: checks if dmove fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 1 $20 dmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: dmove: checks if dmove fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 -2 $20 dmove }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: dmove: checks if dmove fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 -1 $20 dmove }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: qmove: checks if buffer is partially copied.
  given sp0!  create qmovetgt  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  i#−1 d,
        create wmovesrc  q#1 d,  q#2 d,  q#3 d,  q#4 d,  q#5 d,  q#6 d,  q#7 d,  q#8 d,  q#9 d,  q#10 d,  q#11 d,  q#12 d,  q#13 d,  q#14 d,  q#15 d,  q#16 d,  q#17 d,  q#18 d,  q#19 d,  q#20 d,  i#−1 d,
  when: qmovesrc qmovetgt 10 qmove
  then: qmovetgt qmovesrc 10 0 do  swap q@++ rot q@++ rot q!=  loop  drop  10 0 do  q@++ q#0 q!=  loop
        l@ l#-1 !=
        depth 0 !=
  test;

  test: qmove: checks if reverse move is applied when danger of overriding.
  given sp0!
  when: qmovesrc dup q# + 10 qmove
  then: q#12 q#10 q#9 q#8 q#7 q#6 q#5 q#4 q#3 q#2 q#1 q#1 qmovesrc 12 for  q@++ rot d!=  next  drop
        depth 0 !=
  test;

  test: qmove: checks if qmove fails gracefully on an empty stack.
  given sp0!
  when: capture{ qmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: qmove: checks if qmove fails gracefully on an stack with only one entry.
  given sp0!
  when: capture{ $20 qmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 1 !=
  test;

  test: qmove: checks if qmove fails gracefully on an stack with only two entries.
  given sp0!
  when: capture{ 10000 $20 qmove }capture
  then: captured@ ParameterStackUnderflow !=
        depth 2 !=
  test;

  test: qmove: checks if qmove fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 10000 $20 qmove }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: qmove: checks if qmove fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 10000 $20 qmove }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  ( TODO test omove )

  test: c$@++: checks if all UCs are found.
  given sp0!  create c$@++-buffer  "Hэllo, Wørld ㊣!",
  when: '!' '㊣' bl 'd' 'l' 'r' 'ø' 'W' bl ',' 'o' 'l' 'l' 'э' 'H' c$@++-buffer c$@++
  then: dup 15 !=
        0 do  c$@++ rot !=  loop  drop
        depth 0 !=
  test;

  test: c$@++: checks if c$@++ fails gracefully on an empty stack.
  given sp0!
  when: capture{ c$@++ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: $#: checks if length is correct.
  given sp0!  create $#-buffer  "Hэllo, Wørld ㊣!",
  when: $#-buffer $#
  then: 15 !=
        depth 0 !=
  test;

  test: $#: checks if $# fails gracefully on an empty stack.
  given sp0!
  when: capture{ $# }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: $count: checks if the correct unsigned byte is returned and the address is incremented.
  given sp0!  4711
  when: sp@ $count
  then: 103 !=
        sp@ cell+ 1 + !=
        depth 0 !=
  test;

  test: $count: checks if $count fails gracefully on an empty stack.
  given sp0!
  when: capture{ $count }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: $count: checks if $count fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 $count }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: $count: checks if $count fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 $count }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: 0count: checks if the byte is found in the buffer.
  given sp0!  create 0count-buffer  "Hello, world" count 0 do  c$@++ c$,  loop  .--  0 c,
  when: 0count-buffer 0count
  then: 9 !=
        depth 0 !=
  test;

  test: $=: checks that both buffers are equal.
  given sp0!  create $=-buffer_a1  "Hэllo, Wørld ㊣!",  create $=-buffer_a2  "Hэllo, Wørld ㊣!",
  when: $=-buffer_a1 $=-buffer_a2 $=
  then: true !=
        depth 0 !=
  test;

  test: $=: checks that both buffers are different in content.
  given sp0!  create $=-buffer_b1  "Hэllo, Wørld ㊣!",  create $=-buffer_b2  "Hэllo, Wørld ㊢!",
  when: $=-buffer_b1 $=-buffer_b2 $=
  then: false !=
        depth 0 !=
  test;

  test: $=: checks that second buffer is smaller than first one.
  given sp0!  create $=-buffer_c1  "Hэllo, Wørld ㊣!",  create $=-buffer_c2  "Hэllo, Wørld ㊣",
  when: $=-buffer_c1 $=-buffer_c2 $=
  then: false !=
        depth 0 !=
  test;

  test: $=: checks that second buffer is bigger than first one.
  given sp0!  create $=-buffer_c1  "Hэllo, Wørld ㊣",  create $=-buffer_c2  "Hэllo, Wørld ㊣!",
  when: $=-buffer_c1 $=-buffer_c2 $=
  then: false !=
        depth 0 !=
  test;

  test: $=: checks if $= fails gracefully on an empty stack.
  given sp0!
  when: capture{ $= }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: $=: checks if $= fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ $=-buffer_c1 $= }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: $=: checks if $= fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 $= }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: $=: checks if $= fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 $= }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: c$>>: checks if all UCs are found.
  given sp0!  create c$>>-buffer  "Hэllo, Wørld ㊣!",
  when: '!' '㊣' bl 'd' 'l' 'r' 'ø' 'W' bl ',' 'o' 'l' 'l' 'э' 'H' c$>>-buffer c$>>
  then: dup 15 !=
        begin  dup  while  c$>> -rot 2swap !=  repeat
        0 !=  drop
        depth 0 !=
  test;

  test: c$>>: checks if function dies nothing with an empty buffer.
  given sp0!
  when: c$>>-buffer 0 c$>>
  then: −1 !=  c$>>-buffer !=
        depth 0 !=
  test;

  test: c$>>: checks if c$>> fails gracefully on an empty stack.
  given sp0!
  when: capture{ c$>> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c$>>: checks if c$>> fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ c$>>-buffer_c1 c$>> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: c$>>: checks if c$>> fails gracefully with a bad address.
  given sp0!
  when: capture{ -1 1 c$>> }capture
  then: captured@ InvalidMemoryAddress !=
        depth 0 !=
  test;

  test: c$>>: checks if c$>> fails gracefully with a null pointer.
  given sp0!
  when: capture{ 0 1 c$>> }capture
  then: captured@ NullPointer !=
        depth 0 !=
  test;

  test: 0=: checks if the test correctly discovers zero.
  given sp0!
  when: 0 0=
  then: true !=
        depth 0 !=
  test;

  test: 0=: checks if the test correctly discovers non-zero (< 0).
  given sp0!
  when: −42 0=
  then: false !=
        depth 0 !=
  test;

  test: 0=: checks if the test correctly discovers non-zero (> 0).
  given sp0!
  when: 4711 0=
  then: false !=
        depth 0 !=
  test;

  test: 0=: checks if 0= fails gracefully on an empty stack.
  given sp0!
  when: capture{ 0= }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: 0≠: checks if the test correctly discovers zero.
  given sp0!
  when: 0 0≠
  then: false !=
        depth 0 !=
  test;

  test: 0≠: checks if the test correctly discovers non-zero (< 0).
  given sp0!
  when: −42 0≠
  then: true !=
        depth 0 !=
  test;

  test: 0≠: checks if the test correctly discovers non-zero (> 0).
  given sp0!
  when: 4711 0≠
  then: true !=
        depth 0 !=
  test;

  test: 0≠: checks if 0≠ fails gracefully on an empty stack.
  given sp0!
  when: capture{ 0≠ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: 0<: checks if the test correctly discovers zero.
  given sp0!
  when: 0 0<
  then: false !=
        depth 0 !=
  test;

  test: 0<: checks if the test correctly discovers negative.
  given sp0!
  when: −42 0<
  then: true !=
        depth 0 !=
  test;

  test: 0<: checks if the test correctly discovers positive.
  given sp0!
  when: 4711 0<
  then: false !=
        depth 0 !=
  test;

  test: 0<: checks if 0< fails gracefully on an empty stack.
  given sp0!
  when: capture{ 0> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: 0>: checks if the test correctly discovers zero.
  given sp0!
  when: 0 0>
  then: false !=
        depth 0 !=
  test;

  test: 0>: checks if the test correctly discovers negative.
  given sp0!
  when: −42 0>
  then: false !=
        depth 0 !=
  test;

  test: 0>: checks if the test correctly discovers positive.
  given sp0!
  when: 4711 0>
  then: true !=
        depth 0 !=
  test;

  test: 0>: checks if 0> fails gracefully on an empty stack.
  given sp0!
  when: capture{ 0> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: 0≤: checks if the test correctly discovers zero.
  given sp0!
  when: 0 0≤
  then: true !=
        depth 0 !=
  test;

  test: 0≤: checks if the test correctly discovers negative.
  given sp0!
  when: −42 0≤
  then: true !=
        depth 0 !=
  test;

  test: 0≤: checks if the test correctly discovers positive.
  given sp0!
  when: 4711 0≤
  then: false !=
        depth 0 !=
  test;

  test: 0≤: checks if 0≤ fails gracefully on an empty stack.
  given sp0!
  when: capture{ 0≤ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: 0≥: checks if the test correctly discovers zero.
  given sp0!
  when: 0 0≥
  then: true !=
        depth 0 !=
  test;

  test: 0≥: checks if the test correctly discovers negative.
  given sp0!
  when: −42 0≥
  then: false !=
        depth 0 !=
  test;

  test: 0≥: checks if the test correctly discovers positive.
  given sp0!
  when: 4711 0≥
  then: true !=
        depth 0 !=
  test;

  test: 0≥: checks if 0≥ fails gracefully on an empty stack.
  given sp0!
  when: capture{ 0≥ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: =: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 =
  then: true !=
        depth 0 !=
  test;

  test: =: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 =
  then: false !=
        depth 0 !=
  test;

  test: =: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 ≠
  then: false !=
        depth 0 !=
  test;

  test: =: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 =
  then: false !=
        depth 0 !=
  test;

  test: =: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 ≠
  then: false !=
        depth 0 !=
  test;

  test: =: checks if = fails gracefully on an empty stack.
  given sp0!
  when: capture{ = }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: =: checks if = fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 = }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ≠: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 ≠
  then: false !=
        depth 0 !=
  test;

  test: ≠: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 ≠
  then: true !=
        depth 0 !=
  test;

  test: ≠: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 ≠
  then: true !=
        depth 0 !=
  test;

  test: ≠: checks if the test correctly discovers greater.
  given sp0!
  when: 4711 −42 ≠
  then: true !=
        depth 0 !=
  test;

  test: ≠: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 ≠
  then: true !=
        depth 0 !=
  test;

  test: ≠: checks if ≠ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ≠ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ≠: checks if ≠ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 ≠ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: <: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 <
  then: false !=
        depth 0 !=
  test;

  test: <: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 <
  then: true !=
        depth 0 !=
  test;

  test: <: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 <
  then: true !=
        depth 0 !=
  test;

  test: <: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 <
  then: false !=
        depth 0 !=
  test;

  test: <: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 <
  then: false !=
        depth 0 !=
  test;

  test: <: checks if < fails gracefully on an empty stack.
  given sp0!
  when: capture{ < }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: <: checks if < fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 < }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u<: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 u<
  then: false !=
        depth 0 !=
  test;

  test: u<: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 u<
  then: false !=
        depth 0 !=
  test;

  test: u<: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 u<
  then: true !=
        depth 0 !=
  test;

  test: u<: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 u<
  then: true !=
        depth 0 !=
  test;

  test: u<: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 u<
  then: false !=
        depth 0 !=
  test;

  test: u<: checks if u< fails gracefully on an empty stack.
  given sp0!
  when: capture{ u< }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u<: checks if u< fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 u< }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: >: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 >
  then: false !=
        depth 0 !=
  test;

  test: >: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 >
  then: false !=
        depth 0 !=
  test;

  test: >: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 >
  then: false !=
        depth 0 !=
  test;

  test: >: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 >
  then: true !=
        depth 0 !=
  test;

  test: >: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 >
  then: true !=
        depth 0 !=
  test;

  test: >: checks if > fails gracefully on an empty stack.
  given sp0!
  when: capture{ > }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: >: checks if > fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 > }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u>: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 u>
  then: false !=
        depth 0 !=
  test;

  test: u>: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 u>
  then: true !=
        depth 0 !=
  test;

  test: u>: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 u>
  then: false !=
        depth 0 !=
  test;

  test: u>: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 u>
  then: false !=
        depth 0 !=
  test;

  test: u>: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 u>
  then: true !=
        depth 0 !=
  test;

  test: u>: checks if u> fails gracefully on an empty stack.
  given sp0!
  when: capture{ u> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u>: checks if u> fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 u> }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ≤: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 ≤
  then: true !=
        depth 0 !=
  test;

  test: ≤: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 ≤
  then: true !=
        depth 0 !=
  test;

  test: ≤: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 ≤
  then: true !=
        depth 0 !=
  test;

  test: ≤: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 ≤
  then: false !=
        depth 0 !=
  test;

  test: ≤: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 ≤
  then: false !=
        depth 0 !=
  test;

  test: ≤: checks if ≤ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ≤ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ≤: checks if ≤ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 ≤ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u≤: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 u≤
  then: true !=
        depth 0 !=
  test;

  test: u≤: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 u≤
  then: false !=
        depth 0 !=
  test;

  test: u≤: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 u≤
  then: true !=
        depth 0 !=
  test;

  test: u≤: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 u≤
  then: true !=
        depth 0 !=
  test;

  test: u≤: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 u≤
  then: false !=
        depth 0 !=
  test;

  test: u≤: checks if u≤ fails gracefully on an empty stack.
  given sp0!
  when: capture{ u≤ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u≤: checks if u≤ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 u≤ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ≥: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 ≥
  then: true !=
        depth 0 !=
  test;

  test: ≥: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 ≥
  then: false !=
        depth 0 !=
  test;

  test: ≥: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 ≥
  then: false !=
        depth 0 !=
  test;

  test: ≥: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 ≥
  then: true !=
        depth 0 !=
  test;

  test: ≥: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 ≥
  then: true !=
        depth 0 !=
  test;

  test: ≥: checks if ≥ fails gracefully on an empty stack.
  given sp0!
  when: capture{ ≥ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: ≥: checks if ≥ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 ≥ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u≥: checks if the test correctly discovers equality.
  given sp0!
  when: 42 42 u≥
  then: true !=
        depth 0 !=
  test;

  test: u≥: checks if the test correctly discovers less.
  given sp0!
  when: −42 42 u≥
  then: true !=
        depth 0 !=
  test;

  test: u≥: checks if the test correctly discovers absolute less.
  given sp0!
  when: 42 4711 u≥
  then: false !=
        depth 0 !=
  test;

  test: u≥: checks if the test correctly discovers greater.
  given sp0!
  when: 42 −4711 u≥
  then: false !=
        depth 0 !=
  test;

  test: u≥: checks if the test correctly discovers absolute greater.
  given sp0!
  when: 4711 42 u≥
  then: true !=
        depth 0 !=
  test;

  test: u≥: checks if u≥ fails gracefully on an empty stack.
  given sp0!
  when: capture{ u≥ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: u≥: checks if u≥ fails gracefully on a stack with only one entry.
  given sp0!
  when: capture{ 0 u≥ }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: execute: checks if the correct address is invoked.
  given sp0!
  when: 42 4711 ' + >cf execute
  then: 4753 !=
        depth 0 !=
  test;

  test: execute: checks if execute fails gracefully on an empty stack.
  given sp0!
  when: capture{ execute }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

  test: execWord: checks if the correct address is invoked.
  given sp0!
  when: 42 4711 ' + execWord
  then: 4753 !=
        depth 0 !=
  test;

  test: execWord: checks if execWord fails gracefully on an empty stack.
  given sp0!
  when: capture{ execWord }capture
  then: captured@ ParameterStackUnderflow !=
        depth 0 !=
  test;

;
( TODO enhance ALL arithmetic tests by testing with negative values on either and both operands )
