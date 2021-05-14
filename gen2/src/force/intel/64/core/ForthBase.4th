( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The FORTH base vocabulary of FORCE-linux 4.19.0-5-amd64 ******

import /force/intel/64/macro/CoreMacro
package /force/intel/64/core

vocabulary: ForthBase  NoGlobalNames

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

--- In terms of I64 registers: we use
  SS:RSP:  Parameter Stack Pointer
  SS:RBP:  Return Stack Pointer
  RAX:  Top of parameter stack [accumulator]
  DS:RBX:  Current Object Address
  RCX:  Scratch register
  RDX:  Scratch register
  DS:RSI:  Parameter area address
  DS:RDI:  Exception stack pointer
  DS:R08:  Address of class array
  R09:  Scratch register
  R10:  Scratch register
  R11:  Scratch register
  R12:  Scratch register
  DS:R13:  Address of X-Stack Descriptor
  DS:R14:  Address of Y-Stack Descriptor
  DS:R15:  Address of Z-Stack Descriptor
---

public:



=== Constants ===

: cell ( -- cell#:C )  CELL, ;                        ( Cell size )
: %cell ( -- %cell:C )  CELLSHIFT, ;                  ( Cell Shift )
: cell+ ( x -- x+cell# )  CELLPLUS, ;                 ( add cell size to x )
: cells ( n -- n*cell# )  CELLTIMES, ;                ( multiply n with cell size )
: cell/ ( u -- u/cell# )  CELLBY, ;                   ( divide u through cell size )

: half ( -- half#:C )  HALF, ;                        ( Half cell size )
: %half ( -- %half:C )  HALFSHIFT, ;                  ( Half cell Shift )
: half+ ( x -- x+cell# )  HALFPLUS, ;                 ( add half cell size to x )
: halves ( n -- n*cell# )  HALFTIMES, ;               ( multiply n with half cell size )
: half/ ( u -- u/cell# )  HALFBY, ;                   ( divide u through half cell size )

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
Assumption is that the parameter stack grows downwards, all others upwards.
Imposed by the architecture, parameter and return stack reside in the same segment and converge on each other.
The term "stack" without further specification refers to the parameter stack.
------

--- Static Stack State ---

variable PSP0  private                                ( Initial parameter stack pointer )
variable PSS  private                                 ( Parameter stack size in cells )
variable RSP0  private                                ( Initial return stack pointer )
variable RSS  private                                 ( Return stack size in cells )
variable OSP0  private                                ( Initial object stack pointer )
variable OSS  private                                 ( Object stack size in cells )
variable XSP0  private                                ( Initial extra stack pointer )
variable XSS  private                                 ( Extra stack size in cells )
variable YSP0  private                                ( Initial Y-stack pointer )
variable YSS  private                                 ( Y-stack size in cells )
variable ZSP0  private                                ( Initial X-stack pointer )
variable ZSS  private                                 ( Z-stack size in cells )

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
: dupe ( y x -- y y x )  DUPE, ;                      ( duplicate second of stack )
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

--- Fetch and clear ---

: b@0! ( a -- b )  BFETCHZ, ;                         ( fetch signed byte from address )
: c@0! ( a -- c )  CFETCHZ, ;                         ( fetch unsigned byte from address )
: s@0! ( a -- s )  SFETCHZ, ;                         ( fetch signed word from address )
: w@0! ( a -- w )  WFETCHZ, ;                         ( fetch unsigned word from address )
: i@0! ( a -- i )  IFETCHZ, ;                         ( fetch signed double word from address )
: d@0! ( a -- d )  DFETCHZ, ;                         ( fetch unsigned double word from address )
: l@0! ( a -- l )  QFETCHZ, ;                         ( fetch signed quad word from address )
: q@0! ( a -- q )  QFETCHZ, ;                         ( fetch unsigned quad word from address )
: h@0! ( a -- h )  HFETCHZ, ;                         ( fetch signed oct word from address )
: o@0! ( a -- o )  OFETCHZ, ;                         ( fetch unsigned oct word from address )

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

( Store and fetch partially )

: #! ( n a # -- )  #NSTORE, ;                         ( store # least significant bytes of signed n at address a )
: u#! ( u a # -- )  #USTORE, ;                        ( store # least significant bytes of unsigned u at address a )
: #@ ( a # -- n ) #NFETCH, ;                          ( fetch # least significant bytes of signed n at address a )
: u#@ ( a # -- u ) #UFETCH, ;                         ( fetch # least significant bytes of unsigned u at address a )



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
: -> ( a # -- a+1 #-1 )  ADV1, ;  alias −>            ( advance cursor in buffer with address a and length # by 1 )
: #-> ( a # u -- a+u #-u )  ADV, ;  alias #−>         ( advance cursor in buffer with address a and length # by u )
: ->c ( a # -- a+1 #-1 c )  GETCHAR, ;                ( get next character from buffer a# and advance )
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



=== Floating Point Arithmetics ===

--- Constants ---

: 0.0 ( -- F: -- 0.0 )  0.0, ;                        ( Real 0.0 )
: 1.0 ( -- F: -- 1.0 )  1.0, ;                        ( Real 1.0 )
: −1.0 ( -- F: -- −1.0 )  M1.0, ;  alias -1.0         ( Real −1.0 )
: π ( -- F: -- π )  PI, ;  alias pi                   ( pi, the "circle constant" )

--- Memory Operations ---

: f! ( a -- F: f -- )  FSTORE, ;                      ( Store floating point value )


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
: <u< ( u # -- u' )  ROL, ;                           ( rotate u left by # bit positions )
: >u> ( u # -- u' )  ROR, ;                           ( rotate u right by # bit positions )
: <u<c ( u # -- u' )  RCL, ;                           ( rotate u left through carry flag by # bit positions )
: c>u> ( u # -- u' )  RCR, ;                           ( rotate u right through carry flag by # bit positions )

--- Stack Bit Operations ---

( Stack bit operations allow bit indices only up to the number of bits in a cell − 1.  The index is moduloed with the cell size
  by the underlying machine code instruction. )

: bit+ ( x # -- x' )  BSET, ;                         ( set bit # in x )
: bit− ( x # -- x' )  BCLR, ;  alias bit-             ( clear bit # in x )
: bit× ( x # -- x' )  BCHG, ;  alias bit*             ( flip bit # in x )
: bit? ( x # -- ? )  BTST, ;  condition               ( test if bit # in x is set )
: bit?+ ( x # -- x' ? )  BTSET, ;  condition          ( non-atomically test and set bit # in x )
: bit?− ( x # -- x' ? )  BTCLR, ;  condition  alias bit?-       ( non-atomically test and clear bit # in x )
: bit?× ( x # -- x' ? )  BTCHG, ;  condition  alias bit?*       ( non-atomically test and flip bit # in x )
: bit?? ( x # -- x ? )  BTTST, ;  condition           ( test if bit # in x is set )
: bita?+ ( x # -- x' ? )  ABTSET, ;  condition        ( atomically test and set bit # in x )
: bita?− ( x # -- x' ? )  ABTCLR, ;  condition  alias bita?-    ( atomically test and clear bit # in x )
: bita?× ( x # -- x' ? )  ABTCHG, ;  condition  alias bita?*    ( atomically test and flip bit # in x )

--- Memory Bit Operations ---

( Memory bit operations can have quite a big bit index, allowing for potentially huge bit arrays.  The bit index is divided
  through 8 and the result added to the address, then moduloed with 8 to get the bit index in the addressed byte. )

: bit+! ( a # -- )  BSETAT, ;                         ( set bit # at address a )
: bit−! ( a # -- )  BCLRAT, ;  alias bit-!            ( clear bit # at address a )
: bit×! ( a # -- )  BCHGAT, ;  alias bit*!            ( flip bit # at address a )
: bit@ ( a # -- ? )  BTSTAT, ;  condition             ( test if bit # at address a is set )
: bit@+! ( a # -- ? )  BTSETAT, ;  condition          ( non-atomically test and set bit # at address a )
: bit@−! ( a # -- ? )  BTSETAT, ;  condition  alias bit@-!      ( non-atomically test and clear bit # at address a )
: bit@×! ( a # -- ? )  BTSETAT, ;  condition  alias bit@*!      ( non-atomically test and flip bit # at address a )
: bita@+! ( a # -- ? )  ABTSETAT, ;  condition        ( atomically test and set bit # at address a )
: bita@−! ( a # -- ? )  ABTSETAT, ;  condition  alias bita@-!   ( atomically test and clear bit # at address a )
: bita@×! ( a # -- ? )  ABTSETAT, ;  condition  alias bita@*!   ( atomically test and flip bit # at address a )

--- Stack Bit Scan Operations ---

: 1<- ( u -- #|-1 )  BSF1, ;                          ( find position # of least significant 1-bit in u; -1 if u is 0 )
: 1-> ( u -- #|-1 )  BSR1, ;                          ( find position # of most significant 1-bit in u; -1 if u is 0 )
: 0<- ( u -- #|-1 )  BSF0, ;                          ( find position # of least significant 0-bit in u; -1 if u is all 1's )
: 0-> ( u -- #|-1 )  BSR0, ;                          ( find position # of most significant 0-bit in u; -1 if u is all 1's )
: c0<- ( c -- #|-1 )  CBSF0, ;                        ( find position # of least significant 0-bit in c; -1 if c is all 1's )
: c0-> ( c -- #|-1 )  CBSR0, ;                        ( find position # of most significant 0-bit in c; -1 if c is all 1's )

--- Memory Bit Scan Operations ---

( in c...@, #1 is a byte count, whereas in ...@, #1 is a cell count )

: c1<-@ ( a #1 -- #2|-1 )  CBSF1AT, ;                 ( find position #2 of least significant 1-bit in a#1; -1 if all 0's )
: c0<-@ ( a #1 -- #2|-1 )  CBSF0AT, ;                 ( find position #2 of least significant 0-bit in a#1; -1 if all 1's )
: c1->@ ( a #1 -- #2|-1 )  CBSR1AT, ;                 ( find position #2 of most significant 1-bit in a#1; -1 if all 0's )
: c0->@ ( a #1 -- #2|-1 )  CBSR0AT, ;                 ( find position #2 of most significant 0-bit in a#1; -1 if all 1's )
: 1<-@ ( a #1 -- #2|-1 )  BSF1AT, ;                   ( find position #2 of least significant 1-bit in a#1; -1 if all 0's )
: 0<-@ ( a #1 -- #2|-1 )  BSF0AT, ;                   ( find position #2 of least significant 0-bit in a#1; -1 if all 1's )
: 1->@ ( a #1 -- #2|-1 )  BSR1AT, ;                   ( find position #2 of most significant 1-bit in a#1; -1 if all 0's )
: 0->@ ( a #1 -- #2|-1 )  BSR0AT, ;                   ( find position #2 of most significant 0-bit in a#1; -1 if all 1's )

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
  yet been moved. )

: cmove ( sa ta # -- )  CMOVE, ;                      ( move # bytes from block at sa to block at ta )
: wmove ( sa ta # -- )  WMOVE, ;                      ( move # words from block at sa to block at ta )
: dmove ( sa ta # -- )  DMOVE, ;                      ( move # double words from block at sa to block at ta )
: qmove ( sa ta # -- )  QMOVE, ;                      ( move # quad words from block at sa to block at ta )
: omove ( sa ta # -- )  2u* QMOVE, ;                  ( move # oct words from block at sa to block at ta )



=== String Operations ===



=== Vocabulary Operations ===

create VOCABULARIES  1024 cells allot  private        ( Table of loaded vocabularies, 1024 entries )
0 =variable #VOCABULARIES  private                    ( Count of vocabularies )

 0000 dup constant @DICT    private                   ( Address of the dictionary )
cell+ dup constant #DICT    private                   ( Capacity of the dictionary in bytes )
half+ dup constant →DICT    private                   ( Usage of the dictionary in bytes )
half+ dup constant @CODE    private                   ( Address of the code segment )
cell+ dup constant #CODE    private                   ( Capacity of the code segment in bytes )
half+ dup constant →CODE    private                   ( Usage of the code segment in bytes )
half+ dup constant @DATA    private                   ( Address of the data segment )
cell+ dup constant #DATA    private                   ( Capacity of the data segment in bytes )
half+ dup constant →DATA    private                   ( Usage of the data segment in bytes )
half+ dup constant @TEXT    private                   ( Address of the text segment )
cell+ dup constant #TEXT    private                   ( Capacity of the text segment in bytes )
half+ dup constant →TEXT    private                   ( Usage of the text segment in bytes )
half+ dup constant @PARA    private                   ( Address of the parameter table )
cell+ dup constant #PARA    private                   ( Capacity of the parameter table in bytes )
half+ dup constant →PARA    private                   ( Usage of the parameter table in bytes )
half+ dup constant @VMAT    private                   ( Address of the virtual method address table )
cell+ dup constant #VMAT    private                   ( Capacity of the virtual method address table in bytes )
half+ dup constant →VMAT    private                   ( Usage of the virtual method address table in bytes )
half+ dup constant @RELS    private                   ( Address of the relocation table )
cell+ dup constant #RELS    private                   ( Capacity of the relocation table in bytes )
half+ dup constant →RELS    private                   ( Usage of the relocation table in bytes )
half+ dup constant @DEPS    private                   ( Address of the dependency table )
cell+ dup constant #DEPS    private                   ( Capacity of the dependency table in bytes )
half+ dup constant →DEPS    private                   ( Usage of the dependency table in bytes )
half+ dup constant @DBUG    private                   ( Address of the debug segment )
cell+ dup constant #DBUG    private                   ( Capacity of the debug segment in bytes )
half+ dup constant →DBUG    private                   ( Usage of the debug segment in bytes )
half+ dup constant @SYMS    private                   ( Address of the symbol table )
cell+ dup constant #SYMS    private                   ( Capacity of the symbol table in bytes )
half+ dup constant →SYMS    private                   ( Usage of the symbol table in bytes )
half+ dup constant #VOCABULARY                        ( Size of the vocabulary definition )
drop



=== Various ===

--- Code execution ---

: nop ( -- )  NOP, ;                                  ( no operation )
: execute ( cfa -- )  EXECUTE, ;                      ( execute the code at the specified cfa )

--- Type check ---

variable TYPE_CHECKER package-private                 ( Address of the type checker routine )
: !type ( @obj @voc -- @obj -- TypeCastException )  TYPE_CHECKER q@ execute ;    ( assert that @obj is an object of type @voc )

--- Unimplemented ---

variable UNIMPLEMENTED package-private
: unimplemented ( -- )  UNIMPLEMENTED q@ execute ;  ( ran into an unimplemented method: abort )



=== Cell sized aliases ===

: @ ( a -- x )  q@ ;
: ! ( x a -- )  q! ;
: @! ( x a -- x' )  q@! ;
: xchg ( x a -- x' a )  qxchg ;
: +! ( x a -- )  q+! ;
: −! ( x a -- )  q−! ;  alias -!



=== X-Stack ===

create XSTACK  1024 cells allot
variable XSP
: >x ( x -- X: -- x )  XSP @ !  cell XSP +! ;         ( push x on the X stack )
: x> ( -- x X: x -- )  cell XSP -!  XSP @ @ ;         ( pop x from X stack )
: x@ ( -- x X: x -- x )  XSP @ cell - @ ;             ( copy top of X stack onto parameter stack )
: 2x@ ( -- x X: x y - -x y )  XSP @ 2 cells - @ ;     ( copy second of X stack onto parameter stack )
: xdrop ( -- X: x -- )  cell XSP -! ;                 ( drop top of X stack )
: xdepth ( -- n X: -- )  XSP @ XSTACK - cell/ ;       ( Depth of X stack in cells )



=== Module Initialization ===

init: ( @initstr -- @initstr )  dup @PSP + q@ 8− PSP0 q!  dup @RSP + q@ 32+ RSP0 q!  XSTACK XSP ! ;

vocabulary;
