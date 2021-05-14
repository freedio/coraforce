\ MacroForcembler vocabulary for GForth Linux-4.19 amd64

=== Dependencies ===

64 constant _ADDRSIZE
64 constant _OPSIZE
64 constant _ARCH
-1 constant _X87
-1 constant _MMX
-1 constant _XMM

: inv  1 xor ;
: [and] and ;

: ctrl-stack-underflow ( -- )  cr ." Control stack underflow!"  abort ;

create CONTROLSTACK 1024 allot
create CTRLSP  CONTROLSTACK ,
: CTRLDEPTH  CTRLSP @ CONTROLSTACK - cell / ;
: >CTRL  CTRLSP @ !  8 CTRLSP +! ;
: CTRL>  CTRLDEPTH 0= if  ctrl-stack-underflow  then  8 CTRLSP -!  CTRLSP @ @ ;
: CTRL@  CTRLSP @ 8- @ ;
: CTRL2@  CTRLSP @ 16 - @ ;

needs Forcembler.gf



vocabulary MacroForcembler

also Forcembler



=== Definitions ===

7 constant ENTER#                                     ( Number of bytes in the ENTER sequence )
8 constant EXIT#                                      ( Number of bytes in the EXIT sequence )



=== Save and Restore ===

: SAVE, ( -- )  RAX PUSH  %JOIN currentWord@ flags+! ;
: RESTORE, ( -- )  RAX POP  %LINK currentWord@ flags+! ;



=== Parameter Stack ===

: PUSH, ( -- )  RAX PUSH ;
: PUSHPFA, ( &pfa -- )  1 ADP+  SAVE,  dup &>a # RAX MOV  &there 8 - reloc, 1 ADP- ;
: DROP, ( -- )  RAX POP ;
: ZAP, ( -- )  RAX RAX XOR ;



=== Memory Operations ===

: FETCH, ( -- )  0 [RAX] RAX MOV ;



=== Literals ===

: LIT0, ( -- )  SAVE,  EAX EAX XOR ;
: LIT-1, ( -- )  SAVE,  STC  RAX RAX SBB ;
: LIT1, ( b -- )  SAVE,  1 ADP-  # DL MOV  DL RAX MOVSX  1 ADP+ ;
: ULIT1, ( c -- )  SAVE,  1 ADP-  # EAX MOV  1 ADP+ ;
: LIT2, ( s -- )  SAVE,  1 ADP-  # DX MOV  DX RAX MOVSX  1 ADP+ ;
: ULIT2, ( w -- )  SAVE,  1 ADP-  # EAX MOV  1 ADP+ ;
: LIT4, ( i -- )  SAVE,  1 ADP-  # EAX MOV  CDQE  1 ADP+ ;
: ULIT4, ( d -- )  SAVE,  1 ADP-  # EAX MOV  1 ADP+ ;
: LIT8, ( l -- )  SAVE,  1 ADP-  dup nsize  case
    1 of  EAX EAX XOR  # EAX ADD  endof
    2 of  EAX EAX XOR  # EAX ADD  endof
    4 of  EAX EAX XOR  # EAX ADD  endof
    # RAX MOV  endcase  1 ADP+ ;
: ULIT8, ( q -- )  SAVE,  1 ADP-  dup usize  case
    1 of  EAX EAX XOR  # EAX ADD  endof
    2 of  EAX EAX XOR  # EAX ADD  endof
    4 of  # EAX MOV  endof
    # RAX MOV  endcase  1 ADP+ ;
: LITF, ( &f -- )  SAVE,  dup &>a # RAX MOV  -8 +&there reloc,  relocs 1+! ;
: LIT$, ( &$ -- )  SAVE,  dup &>a # RAX MOV  -8 +&there reloc,  relocs 1+! ;
: LIT&, ( & -- )  SAVE,  dup &>a # RAX MOV  -8 +&there reloc,  relocs 1+! ;
: BLANK, ( -- ␣ )  SAVE,  EAX EAX XOR  20 # EAX ADD ;



=== Jump, Call, Return ===

: &JUMP, ( & -- )  # JMP ;
: &CALL, ( & -- )  1 ADP+  dup &>a # CALL  1 ADP-  -4 +&there codereloc,  relocs 1+! ;
: &ICALL, ( & -- )  1 ADP+  dup &>a [] CALL  1 ADP-  -4 +&there codereloc,  relocs 1+! ;
: ENTER, ( -- )  QWORD PTR 0 [RBP] POP  CELL # RBP ADD ;
: EXIT, ( -- )  CELL # RBP SUB  QWORD PTR 0 [RBP] PUSH  RET ;
: EXXIT, ( -- Y: -- reta )  there # NEAR JMP  there >Y ;
: CALLINUX ( # -- )  EAX MOV  SYSCALL ;
: NOP, ( -- )  NOP ;



=== Exception Handling ===

: EXPUSH, ( Exception -- )  RAX 0 [RDI] MOV  CELL [RDI] RDI LEA  RESTORE, ( TODO: check if stack limit exceeded? ) ;
: EXPOP, ( -- Exception )  SAVE,  -CELL [RDI] RDI LEA  0 [RDI] RAX MOV ;



=== Object Orientation ===

: THIS, ( -- a )  SAVE,  RBX RAX MOV ;



=== Clauses ===

: #PICK, ( ... # -- x )  SAVE,  cells [RSP] [RAX] *8 RAX MOV ;
: #DROP, ( # -- )  1- dup 0> if  dup cells # RSP ADD  then  drop  RAX POP ;
: #FETCH, ( # -- )  case
  1 of   BYTE PTR 0 [RAX] RAX MOVZX  endof
  2 of   WORD PTR 0 [RAX] RAX MOVZX  endof
  4 of   0 [RAX] EAX MOV  endof
  8 of   0 [RAX] RAX MOV  endof
  16 of  QWORD PTR CELL [RAX] PUSH  0 [RAX] RAX MOV  endof
  -1 of  BYTE PTR 0 [RAX] RAX MOVSX  endof
  -2 of  WORD PTR 0 [RAX] RAX MOVSX  endof
  -4 of  0 [RAX] EAX MOV  CDQE  endof
  -8 of  0 [RAX] RAX MOV  endof
  -16 of QWORD PTR CELL [RAX] PUSH  0 [RAX] RAX MOV  endof
  10 of  QWORD PTR 0 [RAX] FLD  endof
  cr ." #FETCH: Invalid operand size (expected 2ⁿ|n in ±1,±2,±4,±8): " . abort  endcase ;
: ##FETCH, ( offs # -- )  case
  1 of   BYTE PTR [RAX] RAX MOVZX  endof
  2 of   WORD PTR [RAX] RAX MOVZX  endof
  4 of   [RAX] EAX MOV  endof
  8 of   [RAX] RAX MOV  endof
  16 of  dup cell+ QWORD PTR [RAX] PUSH  [RAX] RAX MOV  endof
  -1 of  BYTE PTR [RAX] RAX MOVSX  endof
  -2 of  WORD PTR [RAX] RAX MOVSX  endof
  -4 of  [RAX] EAX MOV  CDQE  endof
  -8 of  [RAX] RAX MOV  endof
  -16 of  dup cell+ QWORD PTR [RAX] PUSH  [RAX] RAX MOV  endof
  10 of  QWORD PTR [RAX] FLD  endof
  cr ." ##FETCH: Invalid operand size (expected 2ⁿ|n in ±1,±2,±4,±8): " . abort  endcase ;
: #STORE, ( # -- )  dup nsize  case
  8 of  # RDX MOV  RDX 0 [RAX] MOV  endof
  10 of  QWORD PTR 0 [RAX] FSTP  endof
  swap  1 ADP+ # QWORD PTR 0 [RAX] MOV  1 ADP-  RESTORE, endcase ;
: ##STORE, ( offs # -- )  abs case
  1 of  1 ADP+  RDX POP  1 ADP-  DL swap [RAX] MOV  RESTORE,  endof
  2 of  1 ADP+  RDX POP  1 ADP-  DX swap [RAX] MOV  RESTORE,  endof
  4 of  1 ADP+  RDX POP  1 ADP-  EDX swap [RAX] MOV  RESTORE,  endof
  8 of  QWORD PTR [RAX] POP  RESTORE,  endof
  16 of dup QWORD PTR [RAX] POP  cell+ QWORD PTR [RAX] POP  RESTORE,  endof
  10 of  DWORD PTR [RAX] FSTP  endof
  cr ." ##STORE: Invalid operand size (expected 2ⁿ|n in ±1,±2,±4,±8): " . abort  endcase ;
: #CADD, ( # -- )  1 ADP+ # BYTE PTR 0 [RAX] ADD  1 ADP-  RESTORE, ;
: #WADD, ( # -- )  1 ADP+ # WORD PTR 0 [RAX] ADD  1 ADP-  RESTORE, ;
: #DADD, ( # -- )  1 ADP+ # DWORD PTR 0 [RAX] ADD  1 ADP-  RESTORE, ;
: #QADD, ( # -- )  1 ADP+ # QWORD PTR 0 [RAX] ADD  1 ADP-  RESTORE, ;
: #CSUB, ( # -- )  1 ADP+ # BYTE PTR 0 [RAX] SUB  1 ADP-  RESTORE, ;
: #WSUB, ( # -- )  1 ADP+ # WORD PTR 0 [RAX] SUB  1 ADP-  RESTORE, ;
: #DSUB, ( # -- )  1 ADP+ # DWORD PTR 0 [RAX] SUB  1 ADP-  RESTORE, ;
: #QSUB, ( # -- )  1 ADP+ # QWORD PTR 0 [RAX] SUB  1 ADP-  RESTORE, ;
: #PLUS, ( x -- )  case
  0 of  endof
  # RAX ADD  0 endcase ;
: #MINUS, ( x -- )  case
  0 of  exit  endof
  # RAX SUB  0 endcase ;
: #RMINUS, ( x -- )  case
  0 of  exit  endof
  # RAX SUB  RAX NEG  0 endcase ;
: #UTIMES, ( n -- )  case
  0 of  ZAP,  endof
  1 of  exit  endof
  2 of  1 # RAX SHL  endof
  4 of  2 # RAX SHL  endof
  8 of  3 # RAX SHL  endof
  16 of  4 # RAX SHL  endof
  32 of  5 # RAX SHL  endof
  64 of  6 # RAX SHL  endof
  128 of  7 # RAX SHL  endof
  256 of  8 # RAX SHL  endof
  512 of  9 # RAX SHL  endof
  1024 of  10 # RAX SHL  endof
  2048 of  11 # RAX SHL  endof
  4096 of  12 # RAX SHL  endof
  8192 of  13 # RAX SHL  endof
  16384 of  14 # RAX SHL  endof
  32768 of  15 # RAX SHL  endof
  65536 of  16 # RAX SHL  endof
  # RDX MOV  RDX MUL  0 endcase ;
: #TIMES, ( n -- )  case
  0 of  ZAP,  endof
  1 of  exit  endof
  2 of  1 # RAX SHL  endof
  4 of  2 # RAX SHL  endof
  8 of  3 # RAX SHL  endof
  16 of  4 # RAX SHL  endof
  32 of  5 # RAX SHL  endof
  64 of  6 # RAX SHL  endof
  128 of  7 # RAX SHL  endof
  256 of  8 # RAX SHL  endof
  512 of  9 # RAX SHL  endof
  1024 of  10 # RAX SHL  endof
  2048 of  11 # RAX SHL  endof
  4096 of  12 # RAX SHL  endof
  8192 of  13 # RAX SHL  endof
  16384 of  14 # RAX SHL  endof
  32768 of  15 # RAX SHL  endof
  65536 of  16 # RAX SHL  endof
  # RDX MOV  RDX IMUL  0 endcase ;
: #ROUNDUP, ( n -- )  case
  0 of  exit  endof
  1 of  exit  endof
  2 of  1 # RAX ADD  -2 # RAX AND  endof
  4 of  3 # RAX ADD  -4 # RAX AND  endof
  8 of  7 # RAX ADD  -8 # RAX AND  endof
  16 of  15 # RAX ADD  -16 # RAX AND  endof
  32 of  31 # RAX ADD  -32 # RAX AND  endof
  64 of  53 # RAX ADD  -64 # RAX AND  endof
  128 of  127 # RAX ADD  -128 # RAX AND  endof
  256 of  255 # RAX ADD  -256 # RAX AND  endof
  512 of  511 # RAX ADD  -512 # RAX AND  endof
  1024 of  1023 # RAX ADD  -1024 # RAX AND  endof
  2048 of  2047 # RAX ADD  -2048 # RAX AND  endof
  4096 of  4095 # RAX ADD  -4096 # RAX AND  endof
  8192 of  8191 # RAX ADD  -8192 # RAX AND  endof
  16384 of  16383 # RAX ADD  -16384 # RAX AND  endof
  32768 of  32767 # RAX ADD  -32768 # RAX AND  endof
  65536 of  65535 # RAX ADD  -65536 # RAX AND  endof
  # RCX MOV  RCX DEC  RCX RAX ADD  CDQE  RCX INC  RCX IDIV  RCX IMUL  0 endcase ;
: #ADV, ( u -- )  ?dup unless  exit  then  dup # QWORD PTR 0 [RSP] ADD  # RAX SUB ;

--- Conditional Jumps ---

: ?POP ( -- )  there 1- c@ case $50 of  backup  endof  RAX POP  endcase ;

: _setCond ( cc -- )  inv DL swap ?SET  1 # DL SUB  DL RAX MOVSX ;
: _bitOp ( -- )  RESTORE, ;
: _bitTest ( -- )  RAX RAX SBB ;

: #ISEQUAL, ( x -- )  case
  0 of  RAX RAX TEST  0= _setCond  endof
  # RAX CMP  = _setCond  0 endcase ;
: #ISLESS, ( x -- )  case
  0 of  RAX RAX TEST  0< _setCond  endof
  # RAX CMP  < _setCond  0 endcase ;
: #ISGREATER, ( x -- )  case
  0 of  RAX RAX TEST  0> _setCond  endof
  # RAX CMP  > _setCond  0 endcase ;

: #BSET, ( x -- )  # RAX BTS  _bitOp ;
: #BCLR, ( x -- )  # RAX BTR  _bitOp ;
: #BCHG, ( x -- )  # RAX BTC  _bitOp ;
: #BTST, ( x -- )  # RAX BT  _bitTest ;
: #BTSET, ( x -- )  # RAX BTS  RAX PUSH  _bitTest ;
: #BTCLR, ( x -- )  # RAX BTR  RAX PUSH  _bitTest ;
: #BTCHG, ( x -- )  # RAX BTC  RAX PUSH  _bitTest ;
: #BTTST, ( x -- )  # RAX BT  RAX PUSH  _bitTest ;
: #ABTSET, ( x -- )  LOCK  # RAX BTS  RAX PUSH  _bitTest ;
: #ABTCLR, ( x -- )  LOCK  # RAX BTR  RAX PUSH  _bitTest ;
: #ABTCHG, ( x -- )  LOCK  # RAX BTC  RAX PUSH  _bitTest ;

: ?IF, ( cc -- ctrl:a )  ?POP  there # swap [ also ForcemblerTools ] op#1+! [ previous ] ?JMPF  there >CTRL ;
: ?IFEVER, ( cc -- ctrl:a )  ?POP  there # swap [ also ForcemblerTools ] op#1+! [ previous ] LIKELY ?JMPF  there >CTRL ;
: ?UNLESS, ( cc -- ctrl:a )  ?POP  inv there # swap [ also ForcemblerTools ] op#1+! [ previous ] ?JMPF  there >CTRL ;
: ?UNLESSEVER, ( cc -- ctrl:a )  ?POP  inv there # swap [ also ForcemblerTools ] op#1+! [ previous ] LIKELY ?JMPF  there >CTRL ;
: ?UNTIL, ( ctrl:a cc -- )  ?POP  CTRL> # swap [ also ForcemblerTools ] op#1+! [ previous ] ?JMPX ;
: ?WHILE, ( ctrl:a1 cc -- ctrl:a2 ctrl:a1 )  CTRL> swap ?IF, >CTRL ;
: IF, ( -- ctrl:a )  RAX RAX TEST  RAX POP  there # 0= ?JMPF  there >CTRL ;
: IFEVER, ( -- ctrl:a )  RAX RAX TEST  RAX POP  there # 0= LIKELY ?JMPF  there >CTRL ;
: UNLESS, ( -- ctrl:a )  RAX RAX TEST  RAX POP  there # 0≠ ?JMPF  there >CTRL ;
: UNLESSEVER, ( -- ctrl:a )  RAX RAX TEST  RAX POP  there # 0≠ LIKELY ?JMPF  there >CTRL ;
: CONDUPIF, ( -- ctrl:a )  RAX RAX TEST  RAX POP  there # 0= ?JMPF  there >CTRL  RAX PUSH ;
: CONDUPIFEVER, ( -- ctrl:a )  RAX RAX TEST  RAX POP  there # 0= LIKELY ?JMPF  there >CTRL  RAX PUSH ;
: THEN, ( ctrl:a -- )  CTRL> there over - swap 4- d! ;
: ELSE, ( ctrl:a1 -- ctrl:a2 )  CTRL>  0 # JMP  there >CTRL  there over - swap 4- d! ;
: BEGIN, ( -- ctrl:a )  there >CTRL ;
: AGAIN, ( ctrl:a -- )  CTRL> # JMP ;
: UNTIL, ( ctrl:a -- )  RAX RAX TEST  RAX POP  CTRL> # 0= ?JMPX ;
: WHILE, ( ctrl:a1 -- ctrl:a2 ctrl:a1 )  CTRL> IF, >CTRL ;
: REPEAT, ( ctrl:a2 ctrl:a1 -- )  AGAIN, THEN, ;
: DO, ( -- ctrl:a1 ctrl:a2 )  RAX 0 [RSP] CMP  there # < ?JMPF  there >CTRL
  RAX 0 [RBP] MOV  QWORD PTR CELL [RBP] POP  2 CELLS # RBP ADD  there >CTRL ;
: LOOP, ( ctrl:a1 ctrl:a2 -- )  -2CELLS [RBP] RDX MOV  1 # RDX ADD  RDX -2CELLS [RBP] MOV  RDX -CELL [RBP] CMP  CTRL> # < ?JMPX  THEN ;
: MINUS_LOOP, ( ctrl:a1 ctrl:a2 -- )
  -2CELLS [RBP] RDX MOV  RAX RDX SUB  RAX POP  RDX -2CELLS [RBP] MOV  RDX -CELL [RBP] CMP  CTRL> # < ?JMPX  THEN ;
: PLUS_LOOP, ( ctrl:a1 ctrl:a2 -- )
  -2CELLS [RBP] RDX MOV  RAX RDX ADD  RAX POP  RDX -2CELLS [RBP] MOV  RDX -CELL [RBP] CMP  CTRL> # < ?JMPX  THEN ;
: UDO, ( -- ctrl:a1 ctrl:a2 )  RAX 0 [RSP] CMP  there # U< ?JMPF  there >CTRL
  RAX 0 [RBP] MOV  QWORD PTR CELL [RBP] POP  2 CELLS # RBP ADD  there >CTRL ;
: ULOOP, ( ctrl:a1 ctrl:a2 -- )
  -2CELLS [RBP] RDX MOV  1 # RDX ADD  RDX -2CELLS [RBP] MOV  RDX -CELL [RBP] CMP  CTRL> # U< ?JMPX  THEN, ;
: MINUS_ULOOP, ( ctrl:a1 ctrl:a2 -- )
  -2CELLS [RBP] RDX MOV  RAX RDX SUB  RAX POP  RDX -2CELLS [RBP] MOV  RDX -CELL [RBP] CMP  CTRL> # U< ?JMPX  THEN, ;
: PLUS_ULOOP, ( ctrl:a1 ctrl:a2 -- )
  -2CELLS [RBP] RDX MOV  RAX RDX ADD  RAX POP  RDX -2CELLS [RBP] MOV  RDX -CELL [RBP] CMP  CTRL> # U< ?JMPX  THEN, ;
: EXITIF, ( -- )  RAX RAX TEST  there # 0= ?JMPF  there >Y ;
: EXITUNLESS, ( -- )  RAX RAX TEST  there # 0≠ ?JMPF  there >Y ;

previous
