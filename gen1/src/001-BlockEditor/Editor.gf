\ FORCE Editor Linux-4.19 amd64

require ForceEmu.gf

=== Definitions ===

--- Formatting ---

: nprint ( n -- )  base @ >r  decimal  s>d  <# #s #> type  r> base ! ;
: uprint ( u -- )  base @ >r  decimal  0 <# #s #> type  r> base ! ;

--- ANSI Keys ---

$1B constant #esc

create $arrow-up1                       ," \e[1A"
create $arrow-down1                     ," \e[1B"
create $arrow-right1                    ," \e[1C"
create $arrow-left1                     ," \e[1D"
create $win-arrow-up1                   ," \e[1;1A"
create $win-arrow-down1                 ," \e[1;1B"
create $win-arrow-right1                ," \e[1;1C"
create $win-arrow-left1                 ," \e[1;1D"
create $shift-arrow-up1                 ," \e[1;2A"
create $shift-arrow-down1               ," \e[1;2B"
create $shift-arrow-right1              ," \e[1;2C"
create $shift-arrow-left1               ," \e[1;2D"
create $alt-arrow-up1                   ," \e[1;3A"
create $alt-arrow-down1                 ," \e[1;3B"
create $alt-arrow-right1                ," \e[1;3C"
create $alt-arrow-left1                 ," \e[1;3D"
create $shift-alt-arrow-up1             ," \e[1;4A"
create $shift-alt-arrow-down1           ," \e[1;4B"
create $shift-alt-arrow-right1          ," \e[1;4C"
create $shift-alt-arrow-left1           ," \e[1;4D"
create $ctrl-arrow-up1                  ," \e[1;5A"
create $ctrl-arrow-down1                ," \e[1;5B"
create $ctrl-arrow-right1               ," \e[1;5C"
create $ctrl-arrow-left1                ," \e[1;5D"
create $shift-ctrl-arrow-up1            ," \e[1;6A"
create $shift-ctrl-arrow-down1          ," \e[1;6B"
create $shift-ctrl-arrow-right1         ," \e[1;6C"
create $shift-ctrl-arrow-left1          ," \e[1;6D"
create $ctrl-alt-arrow-up1              ," \e[1;7A"
create $ctrl-alt-arrow-down1            ," \e[1;7B"
create $ctrl-alt-arrow-right1           ," \e[1;7C"
create $ctrl-alt-arrow-left1            ," \e[1;7D"
create $shift-ctrl-alt-arrow-up1        ," \e[1;8A"
create $shift-ctrl-alt-arrow-down1      ," \e[1;8B"
create $shift-ctrl-alt-arrow-right1     ," \e[1;8C"
create $shift-ctrl-alt-arrow-left1      ," \e[1;8D"
\ ...

--- ANSI Commands ---

hex
4A325B1B constant #clear-screen
4B5B1B constant #erase-EOL
735B1B constant #saveXY
755B1B constant #restoreXY
: sendANSI ( ucode -- )  begin  dup  while  dup emit  8 rshift  repeat ;
: pushback ( -- )  >in 1-! ;
: match|EXIT ( c -- )  dup key = unless  drop pushback 2exit  then  drop ;
: ureadUntil ( c -- u )  0 begin  key 2 pick over - while  '0' - +  repeat  rot 2drop ;
: readDSR ( -- x y )  1B match|EXIT  '[' match|EXIT  ';' ureadUntil  'R' ureadUntil swap ;
: CSI> ( -- )  1B emit  '[' emit ;
: gotoXY ( x y -- )  CSI>  1+ uprint  ';' emit  1+ uprint  'H' emit ;
: whereXY ( -- x y )  CSI> '6' emit 'n' emit  readDSR ;
: move-up-n ( n -- )  CSI>  uprint  'A' emit ;
: move-down-n ( n -- )  CSI>  uprint  'B' emit ;
: move-right-n ( n -- )  CSI>  uprint  'C' emit ;
: move-left-n ( n -- )  CSI>  uprint  'D' emit ;
: move-up-1 ( -- )  1 move-up-n ;
: move-down-1 ( -- )  1 move-down-n ;
: move-right-1 ( -- )  1 move-right-n ;
: move-left-1 ( -- )  1 move-left-n ;
decimal

--- Dimensions ---

16 constant #rows
64 constant #columns
#rows #columns u* constant buffer-size
buffer-size 4* constant block-size
1 constant minrow
0 constant mincolumn
minrow 1+ constant minrow+1
mincolumn 1+ constant mincolumn+1

=== REPL ===

--- Draw the editor ---

variable posX
variable posY

: clearScreen ( -- )  #clear-screen sendANSI ;
: corner ( -- )  '+' emit ;
: vertical-border ( -- )  '|' emit ;
: horizontal-border ( -- )  ." —" ;
: dashes ( u -- )  for  horizontal-border  next ;
: spaces ( u -- )  for  space  next ;
: drawDashLine ( -- )  corner  #columns dashes  corner ;
: drawHeader ( x y -- x y+1 ) 2dup gotoXY  drawDashLine  1+ ;
: drawFooter ( x y -- x y+1 )  2dup gotoXY  drawDashLine  1+ ;
: drawEditorLine ( x y -- x y+1 )  2dup gotoXY  vertical-border  #columns spaces  vertical-border  1+ ;
: drawEditorLines ( x y n -- x y+n )  for  drawEditorLine  next ;
: drawFrame ( x y -- )  drawHeader  #rows drawEditorLines  drawFooter  gotoXY ;
: drawEditor ( -- )  clearScreen  mincolumn minrow drawFrame ;

--- Navigate the editor ---

variable leftEditor
variable insertMode  -1 insertMode !

: cursor@ ( -- x y )  readDSR minrow+1 + swap mincolumn+1 + swap ;
: cursor! ( x y -- )  2dup  posY ! posX !  minrow+1 + swap mincolumn+1 + swap gotoXY ;
: reposition ( -- )  posX @ mincolumn+1 + posY @ minrow+1 + gotoXY ;
: homeCursor ( -- )  0 0 cursor! ;
: fixColumn ( -- )  posX @ #columns >= if  posX 0!  posY 1+!  then  posX @ 0< if  posX 0!  then ;
: fixRow ( -- )  posY @ #rows 2dup >= if  - dup move-up-n  posY -!  then ;
: fixPosition ( -- )  fixColumn  fixRow  reposition ;
: +>editor ( uc -- )  uc.  posX 1+!  fixPosition ;
: $+>editor ( u$ -- )  count type  posX 1+!  fixPosition ;  \ single unicode character in counted buffer u$

--- Marking ---

: mark-up-1 ( -- ) ***TODO*** ;
: mark-down-1 ( -- ) ***TODO*** ;
: mark-right-1 ( -- ) ***TODO*** ;
: mark-left-1 ( -- ) ***TODO*** ;

--- Document manipulation ---

variable posDoc
create documentPage block-size allot
: +>document ( uc -- )  documentPage posDoc @ 4* + d!  posDoc 1+! ;

--- Process ANSI command ---

create ansiTable
   $arrow-up1 ,                         ' move-up-1 ,
   $arrow-down1 ,                       ' move-down-1 ,
   $arrow-right1 ,                      ' move-right-1 ,
   $arrow-left1 ,                       ' move-left-1 ,
   $win-arrow-up1 ,                     0 ,
   $win-arrow-down1 ,                   0 ,
   $win-arrow-right1 ,                  0 ,
   $win-arrow-left1 ,                   0 ,
   $shift-arrow-up1 ,                   ' mark-up-1 ,
   $shift-arrow-down1 ,                 ' mark-down-1 ,
   $shift-arrow-right1 ,                ' mark-right-1 ,
   $shift-arrow-left1 ,                 ' mark-left-1 ,
   $alt-arrow-up1 ,                     0 ,
   $alt-arrow-down1 ,                   0 ,
   $alt-arrow-right1 ,                  0 ,
   $alt-arrow-left1 ,                   0 ,
   $shift-alt-arrow-up1 ,               0 ,
   $shift-alt-arrow-down1 ,             0 ,
   $shift-alt-arrow-right1 ,            0 ,
   $shift-alt-arrow-left1 ,             0 ,
   $ctrl-arrow-up1 ,                    0 ,
   $ctrl-arrow-down1 ,                  0 ,
   $ctrl-arrow-right1 ,                 0 ,
   $ctrl-arrow-left1 ,                  0 ,
   $shift-ctrl-arrow-up1 ,              0 ,
   $shift-ctrl-arrow-down1 ,            0 ,
   $shift-ctrl-arrow-right1 ,           0 ,
   $shift-ctrl-arrow-left1 ,            0 ,
   $ctrl-alt-arrow-up1 ,                0 ,
   $ctrl-alt-arrow-down1 ,              0 ,
   $ctrl-alt-arrow-right1 ,             0 ,
   $ctrl-alt-arrow-left1 ,              0 ,
   $shift-ctrl-alt-arrow-up1 ,          0 ,
   $shift-ctrl-alt-arrow-down1 ,        0 ,
   $shift-ctrl-alt-arrow-right1 ,       0 ,
   $shift-ctrl-alt-arrow-left1 ,        0 ,
   \ ...
   0 ,                                  0 ,

: execAnsi ( $ -- ? )  \ true if ANSI escape sequence successfully process
  ansiTable  begin  2dup @ dup while
    $$= if
      cell+ @ ?dup if  execute  then
      drop true exit  then
    2 cells+  repeat
  4 #drop 0 ;

--- Process UTF8 buffer ---

: execUTF8 ( $ -- ? )  \ true if UTF8 sequence successfully rendered
  dup c@ 0= if  drop false exit  then
  dup 1+ c@ c|1#>  over c@ - if  drop false exit  then
  $+>editor  true ;

--- in the editor ---

1 constant #ansiseq
2 constant #utf8seq
create composition  32 allot  composition 32 0 cfill
variable compotype

: +ansiseq ( -- )  #ansiseq compotype ! ;
: +utf8seq ( -- )  #utf8seq compotype ! ;
: +>composition ( c -- )  composition tuck count + c!  c1+! ;
: 0>composition ( -- )  composition c0!  compotype 0! ;
: empty ( a$ -- ? )  c@ 0= ;
: insertKey ( c -- )  dup +>document  +>editor ;
: esc:EXIT ( c -- c )  dup #esc = if  +>composition +ansiseq  2exit  then ;
: ascii:EXIT ( c -- c )  dup 7 bit? unless  insertKey  2exit  then ;
: invalidUTF8Start  s" Invalid UTF-8 Start!" exception throw ;
: invalidUTF8Cont  s" Invalid UTF-8 Continuation!" exception throw ;
: !validUTF8Start ( c -- c )  dup %11100000 and %11000000 = unless  invalidUTF8Start  then ;
: !validUTF8Cont ( c -- c )  dup %11000000 and %10000000 = unless  invalidUTF8Cont  then ;
: utf8Start ( c -- )  !validUTF8Start  +>composition +utf8seq ;
: startKey ( c -- )  esc:EXIT  ascii:EXIT  utf8Start ;
: ansiCont ( c -- )  +>composition  composition execAnsi if  0>composition  then ;
: utf8Cont ( c -- )  !validUTF8Cont  +>composition  composition execUTF8 if  0>composition  then ;
: process ( c -- )  compotype @ case
           0 of  startKey  endof
    #ansiseq of  ansiCont  endof
    #utf8seq of  utf8Cont  endof
    s" Invalid composition type!" exception throw  endcase ;
: enterEditor ( -- )  homeCursor  begin  key process  leftEditor @ until ;  \ leave with Alt-ESC (= double ESC)

--- Shell ---

: edit ( -- )  drawEditor  enterEditor  0 minrow+1 1+ gotoXY cr ;
