\ FORCE emulator

: EB $EB ;
: ED $ED ;
: unless  postpone 0=  postpone if ; immediate
: unlessever postpone 0= postpone if ; immediate
: ifever postpone if ; immediate
: 2exit  r> drop  r> drop ;
: #drop ( ... n -- )  0 +do  drop  loop ;
: smash ( x1 x2 -- x1 x1 )  drop dup ;
: rev ( x1 x2 x3 -- x3 x2 x1 )  swap rot ;
: slide ( x1 x2 x3 -- x2 x1 x3 ) rot swap ;
: nip2 ( x1 x2 x3 -- x3 )  -rot 2drop ;
: zap ( x -- 0 )  drop 0 ;
: dupe ( x y -- x x y )  >r dup r> ;
: − ( n1 n2 -- n1−n2 ) - ;
: ≤ ( n1 n2 -- ? ) <= ;
: u≤ ( u1 u2 -- ? ) u<= ;
: ≠ ( n1 n2 -- ? ) <> ;
: << ( x1 n -- x2 )  lshift ;
: u<< ( x1 n -- x2 )  lshift ;
: >> ( x1 n -- x2 )  over 0< if  swap abs rshift negate  else  rshift  then ;
: u>> ( x1 n -- x2 )  rshift ;
: <u< ( x # -- x' )  2dup u<< -rot 64 swap - u>> or ;
: 0- ( n -- ? )  0= 0= ;
: u+ ( u1 u2 -- u3 ) + ;
: u- ( u1 u2 -- u3 ) - ;
: u* ( u1 u2 -- u3 ) * ;
: u/ ( u1 u2 -- u3 ) / ;
: umod ( u1 u2 -- u1%u2 ) mod ;
: ± ( n -- -n )  negate ;
: !and ( u1 u2 -- u3 )  over and 2dup ≠ if  cr ." Warning: Range exceeded!"  then  nip ;
: bit? ( x n -- ? )  1 swap << and 0- ;
: bit- ( x n -- x' )  1 swap << invert and ;
: bit+ ( x n -- x' )  1 swap << or ;
: bit+- ( x n -- x' )  1 swap << xor ;
: bit?- ( x n -- x' ? )  over swap bit- tuck = ;
: c|1#> ( c -- # )  \ counts the number of leading 1s in c
  $80 8 0 do  2dup and unless  2drop i unloop exit  then  2/ loop  2drop 8 ;
: c|0#> ( c -- # )  \ counts the number of leading 0s in c
  $80 8 0 do  2dup and if  2drop i unloop exit  then  2/ loop  2drop 8 ;
: c|0?> ( u -- # )  \ returns the bit# of the highest 0 in c, or -1
  $80 8 0 do  2dup and unless  2drop 7 i - unloop exit  then  2/ loop  2drop -1 ;
: 2+ ( n -- n+2 )  2 + ;
: 2- ( n -- n−2 )  2 - ;
: 4+ ( n -- n-4 )  4 + ;
: 4- ( n -- n-4 )  4 - ;
: 8+ ( n -- n+8 )  8 + ;
: 8- ( n -- n-8 )  8 - ;
: 4* ( n -- n*4 )  2 << ;
: 8* ( n -- n*8 )  3 << ;
: 4/ ( n -- n/8 )  2 >> ;
: 8/ ( n -- n/8 )  3 >> ;
: r- ( n1 n2 -- n2-n1 )  swap - ;
: r− ( n1 n2 -- n2-n1 )  swap - ;
: r! ( a x -- )  swap ! ;
: ->| ( u1 u2 -- n*u2 )  tuck 1- + over / swap * ;          ( Round up u1 to a whole number of u2 [n*u2]. 0 is left as 0 )
: cells+ ( u₁ u₂ -- u₁+u₂×cell )  cells + ;
: cell- ( a -- a-cell )  cell - ;
: cell− ( a -- a-cell )  cell - ;
: 2cells ( -- 2cells )  2 cells ;
: -cell ( -- -cell )  cell negate ;
: -2cells ( -- -2cells )  2 cells negate ;
: -3cells ( -- -3cells )  3 cells negate ;
: -4cells ( -- -4cells )  4 cells negate ;
: cellu/ ( u -- u' )  cell / ;
: cell% ( -- u% )  cell 1 64 0 ?do  2dup <= if  2drop i unloop exit  then  2*  loop  2drop  64 ;
: half ( -- half )  cell 2/ ;
: half% ( -- u% )  cell% 2/ ;
: half+ ( u -- u+half)  half + ;
: c@++ ( a -- c a+1 )  dup c@ swap 1+ ;
: @c++ ( a -- a+1 c )  c@++ swap ;
: --@c ( a -- a-1 c )  1- dup c@ ;
: c@++< ( n a -- n' a+1 )  swap 8 << over c@ + swap 1+ ;
: c@< ( c1 a -- c2 )  c@ swap 8 << + ;
: c!++ ( c a -- a+1 )  tuck c! 1+ ;
: !c++ ( a c -- a+1 )  over c! 1+ ;
: w!++ ( w a -- a+2 )  tuck w! 2+ ;
: !w++ ( a w -- a+2 )  over w! 2+ ;
: !++ ( x a -- a+cell )  tuck ! cell+ ;
: d@ ( a -- d )  ul@ ;
: d! ( d a -- )  l! ;
: d@++ ( a -- d a+1 )  dup d@ swap 4+ ;
: @d++ ( a -- a+1 d )  d@++ swap ;
: !d++ ( a c -- a+1 )  over d! 4+ ;
: i@ ( a -- i )  sl@ ;
: s@ ( a -- s )  sw@ ;
: @++ ( a -- a+cell a@ )  dup cell+ swap @ ;
: @-- ( a -- a-cell a-cell@ )  cell- dup @ ;
: --@ ( a -- a-cell@ a-cell )  @-- swap ;
: --c! ( c a -- a-1 )  1- tuck c! ;
: c!>> ( n a -- n' a+1 )  2dup c!  swap 8 >> swap 1+ ;
: !c>> ( a x -- a+1 x' )  2dup swap c!  8 u>> swap 1+ swap ;
: 0! ( a -- )  0 swap ! ;
: c0! ( a -- )  0 swap c! ;
: -! ( n a -- )  tuck @ swap - swap ! ;
: −! ( n a -- )  tuck @ swap - swap ! ;
: @! ( n1 a -- n2 )  dup @ -rot ! ;
: xchg ( n1 a -- n2 a )  dup @ -rot tuck ! ;
: @0! ( a -- @a )  dup @ swap 0! ;
: #! ( x a # -- )  case
  1 of  c!  endof
  2 of  w!  endof
  4 of  d!  endof
  8 of  !  endof
  cr ." Invalid size: " . abort  endcase ;
: c1+! ( a -- )  dup c@ 1+ swap c! ;
: c+! ( c a -- )  dup c@ rot + swap c! ;
: c-! ( c a -- )  dup c@ rot - swap c! ;
: 1+! ( a -- )  dup @ 1+ swap ! ;
: 1-! ( a -- )  dup @ 1- swap ! ;
: andn ( n1 n2 -- n1&¬n2 )  invert and ;
: andn! ( n a -- )  dup @ rot andn swap ! ;
: or!  ( n a -- )  dup @ rot or swap ! ;
: xor!  ( n a -- )  dup @ rot xor swap ! ;
: cor! ( c a -- )  dup c@ rot or swap c! ;
: wor! ( w a -- )  dup w@ rot or swap w! ;
: dor! ( d a -- )  dup d@ rot or swap d! ;
: b>n ( b -- n )  dup 128 256 within if  -1 $ff xor +  then ;
: bits ( # -- %n )  -1  cell 8* rot -  u>> ;
: nsize ( n -- # )  dup if
  dup -128 128 within if  drop 1  else
  dup -32768 32768 within if  drop 2  else
  dup -2147483648 2147483648 within if  drop 4  else  drop 8  then then then then ;
: usize ( u -- # )  dup if
  dup 0 256 within if  drop 1  else
  dup 0 65536 within if  drop 2  else
  dup 0 4294967296 within if  drop 4  else  drop 8  then then then then ;
: -> ( a # -- a+1 #-1 )  1- swap 1+ swap ;
: #-> ( a # u -- a+u #-u )  tuck - -rot + swap ;
: nextchar ( a # -- a+1 #-1 c )  1- swap dup 1+ -rot c@ ;
: regress ( a # -- a-1 #+1 )  1+ swap 1- swap ;
: =variable ( x -- )  create , ;
: bytevar  create 0 c, ;
: type$ ( $ -- )  count type ;
: qtype$ ( $ -- )  '"' emit  count type  '"' emit ;
: qtype ( a # -- )  '"' emit  type  '"' emit ;
: hexb. ( c -- )  dup 4 u>> dup 9 > 7 and + '0' + emit $F and dup 9 > 7 and + '0' + emit ;
: addr. ( a -- )  60 begin dup 4+ while  2dup >> $F and dup 9 > 7 and + '0' + emit  4 - repeat  2drop ;
: append ( a1 a2 # -- a2' )  2dup + >r cmove r> ;

: hexdump ( a # -- a # )  2dup  cr  over addr. ." : " 0 ?do dup c@ hexb. space 1+ loop  drop ;
: bare-hexline ( a # -- )  0 ?do dup c@ hexb. space 1+ loop  drop ;
: u. ( u -- )  0 <# #s #> type ;

: hexline ( a # -- )
  CR OVER 0 <# # # # # # # # # # # # # #> type space
  2DUP 16 0 DO
    I 8 = IF  45 EMIT  ELSE  SPACE  THEN
    DUP 0> IF  OVER C@ 0 <# # # #> type  ELSE  2 spaces  THEN
    1- SWAP 1+ SWAP LOOP
  2DROP 10 spaces
  16 0 DO
\   I 8 = IF  space  THEN
    DUP 0> IF
      OVER C@ DUP bl < OVER $7F > OR IF  DROP '.'  ELSE DUP bl = IF  DROP 2422  THEN  THEN
      XEMIT  ELSE  space  THEN
    1- SWAP 1+ SWAP LOOP
  2DROP ;

: hexdumpf ( a # -- )
  BEGIN
    DUP 0> WHILE
    2DUP ['] hexline #16 base-execute
    16 - SWAP 16 + SWAP
    REPEAT
  2DROP ;



: $$#= ( a1 a2 # -- ? )
  0 ?do 2dup c@ swap c@ = unless  2drop unloop false exit then 1+ swap 1+ loop  2drop true ;

: $$= ( $1 $2 -- ? )
    \ Compare counted strings a1 and a2 for equality.
    COUNT ROT COUNT ( a1 #1 a2 #2 )
    ROT OVER - IF  2DROP DROP FALSE EXIT  THEN
    0 ?DO 2DUP C@ SWAP C@ - IF  UNLOOP 2DROP FALSE EXIT  THEN
        1+ SWAP 1+ LOOP
    2DROP TRUE ;

: $$?= ( $1 $2 -- ? )
    \ Compare counted strings a1 and a2 for equality.
    2dup cr ." Comparing «" type$ ." » with «" type$ ." »"
    COUNT ROT COUNT ( a1 #1 a2 #2 )
    ROT OVER - IF  2DROP DROP FALSE EXIT  THEN
    0 ?DO
      2DUP C@ SWAP C@ - IF  UNLOOP 2DROP FALSE EXIT  THEN
      1+ SWAP 1+ LOOP
    2DROP TRUE ;

: $$> ( $1 $2 -- ? )  \ Check if $1 starts with $2
  COUNT ROT COUNT  2SWAP  ROT OVER  <= IF  2DROP DROP FALSE EXIT  THEN
  0 ?DO  2DUP C@ SWAP C@ - IF  UNLOOP 2DROP FALSE EXIT  THEN
     1+ SWAP 1+ LOOP
  2DROP TRUE ;

: commentbracket ( a -- )
    \ Skip words until word a is encountered.
    BEGIN
        DUP BL WORD DUP C@ 0= IF
            ABORT" Isolated comment bracket!" THEN
        $$= UNTIL
    DROP ;

: textbracket ( a -- )
  BEGIN
    DUP BL WORD DUP C@ 0= IF
      2DROP REFILL UNLESS  ABORT" Isolated text bracket!" THEN  FALSE
      ELSE $$= THEN UNTIL
    DROP ;

: === ( -- )  c" ===" commentbracket ;
: --- ( -- )  c" ---" commentbracket ;
: ------ ( -- )  c" ------" textbracket ;

: udo postpone u+do ; immediate

( Number of bits in quantity |  Shift count for byte quantity | Shift count for bit quantity )
  8 constant byte#              0 constant byte%                3 constant byte^
 16 constant word#              1 constant word%                4 constant word^
 32 constant dword#             2 constant dword%               5 constant dword^
 64 constant qword#             3 constant qword%               6 constant qword^
 80 constant tbyte#
128 constant oword#             4 constant oword%               7 constant oword^
256 constant hword#             5 constant hword%               8 constant hword^

( Number of bits in the specified binary quantity )
: bytes# ( u1 -- u2 )   byte^ << ;
: words# ( u1 -- u2 )   word^ << ;
: dwords# ( u1 -- u2 )  dword^ << ;
: qwords# ( u1 -- u2 )  qword^ << ;
: tbytes# ( u1 -- u2 )  tbyte# * ;
: owords# ( u1 -- u2 )  oword^ << ;
: hwords# ( u1 -- u2 )  hword^ << ;

( Number of bytes in quantity | Mask for unsigned quantity |  Mask for signed quantity )
1 constant #byte          $FF constant %ubyte                 $7F constant %byte
2 constant #word          $FFFF constant %uword               $7FFF constant %word
4 constant #dword         $FFFFFFFF constant %udword          $7FFFFFFF constant %dword
8 constant #qword         $FFFFFFFFFFFFFFFF constant %uqword  $7FFFFFFFFFFFFFFF constant %qword
10 constant #tbyte
16 constant #oword
32 constant #hword

( Number of bytes in specified binary quantity )
: #bytes ( u1 -- u1 )  byte% << ;
: #words ( u1 -- u2 )  word% << ;
: #dwords ( u1 -- u2 )  dword% << ;
: #qwords ( u1 -- u2 )  qword% << ;
: #tbytes ( u1 -- u2 )  10 * ;
: #owords ( u1 -- u2 )  oword% << ;
: #hwords ( u1 -- u2 )  hword% << ;

: alias  latest name>int alias ; immediate
: stackcheck  depth if  .s  depth 0 do  drop  loop  then ;
: 0allot ( u -- )  here over allot swap 0 fill ;
: w,  here w! 2 allot ;
: d,  here d! 4 allot ;
: >mask ( n -- %n )
  -128 128 within if  $FF  else  -65536 65536 within if $FFFF else $FFFFFFFF  then  then ;
: sp/ ( ... -- )  depth 0 ?do drop loop ;
: .sh  base @ >r hex .s r> base ! ;

create ASTACK 1024 allot
create ASP  ASTACK ,
: A?  ASP @ ASTACK - cell / ;
: >A  ( cr ." ---- " dup hex. ." >A[" A? 0 <# #s #> type ']' emit )   ASP @ !  8 ASP +! ;
: A>  8 ASP -!  ASP @ @  ( cr ." ---- A[" A? 0 <# #s #> type ." ]> " dup hex. ) ;
: A@  ASP @ 8- @ ;

create BSTACK 1024 allot
create BSP  BSTACK ,
: >B  BSP @ !  8 BSP +! ;
: B>  8 BSP -!  BSP @ @ ;
: B@  BSP @ 8- @ ;
: B2@  BSP @ 16 - @ ;
: BDEPTH  BSP @ BSTACK - cell / ;

create XSTACK 4096 allot
create XSP  XSTACK ,
: >X  XSP @ !  8 XSP +! ;
: X>  8 XSP -!  XSP @ @ ;
: X@  XSP @ 8- @ ;
: 2X@  XSP @ 16 - @ ;
: XDROP  8 XSP -! ;
: XDEPTH  XSP @ XSTACK - cell / ;

create YSTACK 1024 allot
create YSP  YSTACK ,
: >Y  YSP @ !  8 YSP +! ;
: Y>  8 YSP -!  YSP @ @ ;
: Y@  YSP @ 8- @ ;
: YDEPTH  YSP @ YSTACK - cell / ;

: there  here ;
: toff 0 ;
: tc,  c, ;
: tw,  w, ;
: td,  d, ;
: t,  , ;
: dataReloc,  cr ." ---- dataReloc: wrong!" .sh 4 #drop ;
: codeReloc,  cr ." ---- codeReloc: wrong!" .sh 3 #drop ;
: assertCodeSpace ( u -- ) drop ;

: cfill ( a # c -- )  fill ;
: $/ ( $1 -- $1 )  0 over c! ;                        ( clear $1 )
: a#+>$ ( $1 a # -- $1 )  dup >r 2 pick count + swap cmove r> over c+! ;    ( append a# to $1 )
: $+>$ ( $1 $2 -- $1 )  count a#+>$ ;                 ( append $2 to $1 )
: a#>$ ( $1 a # -- $1 )  2 pick c0!  a#+>$ ;          ( copy a# to $1 )
: $>$ ( $1 $2 -- $1 )  over c0!  $+>$ ;               ( copy $2 to $1 )
: c+>$ ( $1 c -- $1 )  over count + c!  dup c1+! ;    ( append c to $1 )
: ?c+>$ ( $1 c -- $1 )                                ( append c to $1 if there is none at the end of $1 )
  over count + 1- c@ over = unless  c+>$  else  drop  then ;
: u+>$ ( $1 u -- $1 )  0 <# #s #> a#+>$ ;             ( append u to S1 )
: $$=<| ( $1 $2 -- ? )                                ( Checks if $2 and $1 end equally )
  over c@ over c@ min -rot  count + swap count +
  rot 0 do  1- dup c@  rot 1- dup c@  rot = unless  2drop false unloop exit  then  loop  2drop true ;

: ***TODO***  s" Unimplemented Code!" exception throw ;
: uc. ( uc -- )  begin  dup while  dup emit  8 >>  repeat  drop ;
: c@> ( a # -- a' #' c|-1 )  2dup if  c@ rot 1+ rot 1- rot  else  drop -1  then ;
variable utf8-char
: uc+ ( a # -- a' #' )    ( adds one utf8-byte to utf8-char, or -1 if bad sequence / end of string )
  utf8-char @ 1+ if         ( if still valid )
    c@> dup 1+ if           ( if another char )
      dup c|1#> 1 = if      ( if char is utf8-compliant )
        %111111 and  utf8-char @ 6 << +  utf8-char !  exit  then  then    ( shift value under utf8-char and exit )
    drop  -1 utf8-char !    ( all other cases report -1 )
  then ;
: uc@> ( a # -- a' #' uc|-1 )  utf8-char 0!    ( read a UTF8 character, or -1 if EOS or bad sequence )
  c@> dup 1+ unless  exit  then    ( end of string -> -1 )
  dup c|0?> case
    7 of  exit  endof                                            ( 1 byte UTF8 )
    5 of  $1F and utf8-char !  uc+  utf8-char @ endof            ( 2 byte UTF8 )
    4 of  $0F and utf8-char !  uc+ uc+  utf8-char @ endof        ( 3 byte UTF8 )
    3 of  $07 and utf8-char !  uc+ uc+ uc+  utf8-char @ endof    ( 4 byte UTF8 )
    drop -1  endcase ;
: cfind ( a # c -- #+1|0 )  -rot 0 ?do  dup c@  2 pick = if  2drop i 1+ unloop exit  then  1+  loop  2drop 0 ;
: cfindlast ( a # c -- #+1|0 )
  -rot dup >x + x@ 0 ?do  1-  dup c@  2 pick = if  2drop x> i - unloop exit  then  loop  x> drop 2drop 0 ;
: cxafterlast ( a # c -- a' #' )  >r 2dup r> cfindlast tuck - -rot + swap ;
: inline ( -- ) ;
: !uword ( x -- x )  dup 0 65536 within unless  cr ." Not an unsigned word: " . abort  then ;
: !u4 ( x -- x )  dup 32 u>> if  cr ." Expected unsigned 32-bit value, but got " . abort  then ;
: !n4 ( x -- x )  dup abs 32 u>> if  cr ." Expected signed 32-bit value, but got " . abort  then ;
