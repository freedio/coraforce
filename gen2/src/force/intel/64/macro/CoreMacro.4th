( Copyright © 2020 by Coradec GmbH.  All rights reserved. )

=== Core Macro Forcembler Vocabulary ===

( For portability reasons, never put assembly code directly into words.  Instead, create a macro forcembler vocabulary and
  wrap the assembler code into a macro.  This way, only the macro forcembler vocabularies need to be ported.
)

( Register Usage:
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
)

package /force/intel/64/macro

vocabulary: CoreMacro  NoGlobalNames

=== Helpers ===

code: SAVE, ( -- )  RAX PUSH ; join
code: RESTORE, ( -- )  RAX POP ; link
code: ENTER, ( -- )  QWORD PTR 0 [RBP] POP  CELL # RBP ADD ;
code: EXIT, ( -- )  CELL # RBP SUB  QWORD PTR 0 [RBP] PUSH  RET ;



=== Constants ===

code: CELL, ( -- cell# )  SAVE,  EAX EAX XOR  CELL # EAX ADD ;
code: CELLSHIFT, ( -- #cell )  SAVE,  EAX EAX XOR  CELL 8 * # EAX ADD ;
code: CELLPLUS, ( u -- u+cell# )  CELL # RAX ADD ;
code: CELLTIMES, ( u -- u×cell# )  CELL% # RAX SHL ;
code: CELLBY, ( u×cell# -- u )  CELL% # RAX SHR ;

code: HALF, ( -- half# )  SAVE,  EAX EAX XOR  HALF # EAX ADD ;
code: HALFSHIFT, ( -- #half )  SAVE,  EAX EAX XOR  HALF 8 * # EAX ADD ;
code: HALFPLUS, ( u -- u+half# )  HALF # RAX ADD ;
code: HALFTIMES, ( u -- u×half# )  HALF% # RAX SHL ;
code: HALFBY, ( u×half# -- u )  HALF% # RAX SHR ;

code: BLANK, ( -- ␣ )  SAVE,  EAX EAX XOR  $20 # EAX ADD ;



=== Stack Operations ===

--- Parameter Stack ---

code: GETSP, ( -- @sp )  SAVE,  RSP RAX MOV ;
code: SETSP, ( @sp -- )  RAX RSP MOV ;

code: DUP, ( x -- x x )  RAX PUSH ;
code: TRIP, ( x -- x x x )  RAX PUSH  RAX PUSH ;
code: DROP, ( x -- )  RAX POP ;
code: ZAP, ( x -- 0 )  EAX EAX XOR ;
code: SWAP, ( x2 x1 -- x1 x2 )  RAX 0 [RSP] XCHG ;
code: SMASH, ( x2 x1 -- x2 x2 )  0 [RSP] RAX MOV ;
code: OVER, ( x2 x1 -- x2 x1 x2 )  SAVE,  CELL [RSP] RAX MOV ;
code: TUCK, ( x2 x1 -- x1 x2 x1 )  RAX 0 [RSP] XCHG  RAX PUSH  CELL [RSP] RAX MOV ;
code: NIP, ( x2 x1 -- x1 )  CELL # RSP ADD ;
code: NIP2, ( x1 x2 x3 -- x3 )  2 CELLS # RSP ADD ;
code: ROT, ( x3 x2 x1 -- x2 x1 x3 )  RAX 0 [RSP] XCHG  RAX CELL [RSP] XCHG ;
code: ROTR, ( x3 x2 x1 -- x1 x3 x2 )  RAX CELL [RSP] XCHG  RAX 0 [RSP] XCHG ;
code: SLIDE, ( x3 x2 x1 -- x2 x3 x1 )  0 [RSP] RDX MOV  CELL [RSP] RDX XCHG  RDX 0 [RSP] MOV ;
code: REV, ( x3 x2 x1 -- x1 x2 x3 )  CELL [RSP] RAX XCHG ;
code: 2DUP, ( x1 y1 -- x1 y1 x1 y1 )  RAX PUSH  CELL PTR CELL [RSP] PUSH ;
code: DUPE, ( x y -- x x y )  CELL PTR CELL [RSP] PUSH ;
code: 2DROP, ( x1 y1 -- )  CELL # RSP ADD  RESTORE, ;
code: 2SWAP, ( x2 y2 x1 y1 -- x1 y1 x2 y2 )  RDX POP  RDX CELL [RSP] XCHG  RAX 0 [RSP] XCHG  RDX PUSH ;
code: 2NIP, ( x2 y2 x1 y1 -- x1 y1 )  RDX POP  2 CELLS # RSP ADD  RDX PUSH ;
code: 2OVER, ( x2 y2 x1 y1 -- x2 y2 x1 y1 x2 y2 )  SAVE,  CELL PTR 3 CELLS [RSP] PUSH  3 CELLS [RSP] RAX MOV ;
code: PICK, ( ... u -- ... uth )  0 [RSP] [RAX] *CELL RAX MOV ;
code: ROLL, ( x1 x2 ... xu u -- x2 .. xu x1 )  EAX ECX MOV  RAX POP  EDX EDX XOR
  BEGIN  1 # ECX SUB  0> WHILE  0 [RSP] [RDX] *CELL RAX XCHG  EDX INC  REPEAT ;
code: ROLLR, ( x1 x2 ... xu u -- xu x1 x2 ... )  EAX ECX MOV  RAX POP
  BEGIN  1 # ECX SUB  0> WHILE  -CELL [RSP] [RCX] *CELL RAX XCHG  REPEAT ;
code: ?DUP, ( x|0 -- x x | 0 )  RAX RAX TEST  0= UNLESSLIKELY  RAX PUSH  THEN ;

--- Return Stack ---

code: GETRP, ( -- @rp )  SAVE,  RBP RAX MOV ;
code: SETRP, ( @rp -- )  RAX RBP MOV  RESTORE, ;
code: FROMR, ( -- x R: x -- )  SAVE,  0 [RBP] RAX MOV  CELL # RBP ADD ;
code: TOR, ( x -- R: -- x )  RAX 0 [RBP] MOV  CELL # RBP ADD  RESTORE, ;
code: RFETCH, ( -- x R: x -- x )  SAVE,  -CELL [RBP] RAX MOV ;
code: RCOPY, ( x -- x R: -- x )  RAX 0 [RBP] MOV  CELL # RBP ADD ;
code: RDROP, ( -- R: x -- )  CELL # RBP SUB ;
code: RDUP, ( -- R: x -- x x )  -CELL [RBP] RDX MOV  RDX 0 [RBP] MOV  CELL # RBP ADD ;
code: LOOPINDEX, ( -- i R: l i -- l i )  SAVE,  -2CELLS [RBP] RAX MOV ;
code: LOOPLIMIT, ( -- l R: l i -- l i )  SAVE,  -CELL [RBP] RAX MOV ;
code: LOOPINDEX2, ( -- i R: l1 i1 l2 i2 -- l1 i1 l2 i2 )  SAVE,  -4CELLS [RBP] RAX MOV ;
code: LOOPLIMIT2, ( -- l R: l1 i1 l2 i2 -- l1 i1 l2 i2 )  SAVE,  -3CELLS [RBP] RAX MOV ;
code: 2RDROP, ( -- R: x y -- )  2CELLS # RBP SUB ;



=== Memory Operations ===

code: CSTORE, ( c a -- )  RDX POP  DL 0 [RAX] MOV  RESTORE, ;
code: WSTORE, ( w a -- )  RDX POP  DX 0 [RAX] MOV  RESTORE, ;
code: DSTORE, ( d a -- )  RDX POP  EDX 0 [RAX] MOV  RESTORE, ;
code: QSTORE, ( q a -- )  QWORD PTR 0 [RAX] POP  RESTORE, ;
code: OSTORE, ( o a -- )  QWORD PTR 0 [RAX] POP  QWORD PTR CELL [RAX] POP  RESTORE, ;

code: BFETCH, ( @b -- b )  BYTE PTR 0 [RAX] RAX MOVSX ;
code: CFETCH, ( @c -- c )  BYTE PTR 0 [RAX] RAX MOVZX ;
code: SFETCH, ( @s -- s )  WORD PTR 0 [RAX] RAX MOVSX ;
code: WFETCH, ( @w -- w )  WORD PTR 0 [RAX] RAX MOVZX ;
code: IFETCH, ( @i -- i )  0 [RAX] EAX MOV  CDQE ;
code: DFETCH, ( @i -- i )  0 [RAX] EAX MOV ;
code: LFETCH, ( @l -- l )  0 [RAX] RAX MOV ;
code: QFETCH, ( @q -- q )  0 [RAX] RAX MOV ;
code: HFETCH, ( @h -- h )  QWORD PTR CELL [RAX] PUSH  0 [RAX] RAX MOV ;
code: OFETCH, ( @h -- h )  QWORD PTR CELL [RAX] PUSH  0 [RAX] RAX MOV ;

code: BFETCHZ, ( @b -- b )  BYTE PTR 0 [RAX] RDX MOVSX  0 # BYTE PTR 0 [RAX] MOV  RDX RAX MOV ;
code: CFETCHZ, ( @c -- c )  BYTE PTR 0 [RAX] RDX MOVZX  0 # BYTE PTR 0 [RAX] MOV  RDX RAX MOV ;
code: SFETCHZ, ( @s -- s )  WORD PTR 0 [RAX] RDX MOVSX  0 # WORD PTR 0 [RAX] MOV  RDX RAX MOV ;
code: WFETCHZ, ( @w -- w )  WORD PTR 0 [RAX] RDX MOVZX  0 # WORD PTR 0 [RAX] MOV  RDX RAX MOV ;
code: IFETCHZ, ( @i -- i )  EDX EDX XOR  0 [RAX] EDX XCHG  RDX RAX MOV  CDQE ;
code: DFETCHZ, ( @i -- i )  EDX EDX XOR  0 [RAX] EDX XCHG  RDX RAX MOV ;
code: LFETCHZ, ( @l -- l )  EDX EDX XOR  0 [RAX] RDX XCHG  RDX RAX MOV ;
code: QFETCHZ, ( @q -- q )  EDX EDX XOR  0 [RAX] RDX XCHG  RDX RAX MOV ;
code: HFETCHZ, ( @h -- h )  QWORD PTR CELL [RAX] PUSH  EDX EDX XOR  RDX CELL [RAX] MOV  0 [RAX] RDX XCHG  RDX RAX MOV ;
code: OFETCHZ, ( @h -- h )  QWORD PTR CELL [RAX] PUSH  EDX EDX XOR  RDX CELL [RAX] MOV  0 [RAX] RDX XCHG  RDX RAX MOV ;

code: STORECINC, ( a c -- a+1 )  RAX RDX MOV  RAX POP  DL 0 [RAX] MOV  RAX INC ;
code: STOREWINC, ( a w -- a+2 )  RAX RDX MOV  RAX POP  DX 0 [RAX] MOV  2 # RAX ADD ;
code: STOREDINC, ( a d -- a+4 )  RAX RDX MOV  RAX POP  EDX 0 [RAX] MOV  4 # RAX ADD ;
code: STOREQINC, ( a q -- a+8 )  RAX RDX MOV  RAX POP  RDX 0 [RAX] MOV  8 # RAX ADD ;
code: STOREOINC, ( a o -- a+16 )  RCX POP  RAX RDX MOV  RAX POP  RCX CELL [RAX] MOV  RDX 0 [RAX] MOV  16 # RAX ADD ;

code: CSTOREINC, ( c a -- a+1 )  RDX POP  DL 0 [RAX] MOV  RAX INC ;
code: WSTOREINC, ( w a -- a+2 )  RDX POP  DX 0 [RAX] MOV  2 # RAX ADD ;
code: DSTOREINC, ( d a -- a+4 )  RDX POP  EDX 0 [RAX] MOV  4 # RAX ADD ;
code: QSTOREINC, ( q a -- a+8 )  QWORD PTR 0 [RAX] POP  8 # RAX ADD ;
code: OSTOREINC, ( o a -- a+16 )  QWORD PTR 0 [RAX] POP  QWORD PTR CELL [RAX] POP  16 # RAX ADD ;

code: DECSTOREC, ( a c -- a−1 )  RAX RDX MOV  RAX POP  1 # RAX SUB  DL 0 [RAX] MOV ;
code: DECSTOREW, ( a w -- a−2 )  RAX RDX MOV  RAX POP  2 # RAX SUB  DX 0 [RAX] MOV ;
code: DECSTORED, ( a d -- a−4 )  RAX RDX MOV  RAX POP  4 # RAX SUB  EDX 0 [RAX] MOV ;
code: DECSTOREQ, ( a q -- a−8 )  RAX RDX MOV  RAX POP  8 # RAX SUB  RDX 0 [RAX] MOV ;
code: DECSTOREO, ( a o -- a−16 )  RCX POP  RAX RDX MOV  RAX POP  16 # RAX SUB  RCX CELL [RAX] MOV  RDX 0 [RAX] MOV ;

code: DECCSTORE, ( c a -- a−1 )  RDX POP  1 # RAX SUB  DL 0 [RAX] MOV ;
code: DECWSTORE, ( w a -- a−2 )  RDX POP  2 # RAX SUB  DX 0 [RAX] MOV ;
code: DECDSTORE, ( d a -- a−4 )  RDX POP  4 # RAX SUB  EDX 0 [RAX] MOV ;
code: DECQSTORE, ( q a -- a−8 )  8 # RAX SUB  QWORD PTR 0 [RAX] POP ;
code: DECOSTORE, ( o a -- a−16 )  16 # RAX SUB  QWORD PTR 0 [RAX] POP  QWORD PTR CELL [RAX] POP ;

code: BFETCHINC, ( a -- a+1 b )  RAX INC  RAX PUSH  BYTE PTR -1 [RAX] RAX MOVSX ;
code: CFETCHINC, ( a -- a+1 c )  RAX INC  RAX PUSH  BYTE PTR -1 [RAX] RAX MOVZX ;
code: SFETCHINC, ( a -- a+2 s )  2 # RAX ADD  RAX PUSH  WORD PTR -2 [RAX] RAX MOVSX ;
code: WFETCHINC, ( a -- a+2 w )  2 # RAX ADD  RAX PUSH  WORD PTR -2 [RAX] RAX MOVZX ;
code: IFETCHINC, ( a -- a+4 i )  4 # RAX ADD  RAX PUSH  -4 [RAX] EAX MOV  CDQE ;
code: DFETCHINC, ( a -- a+4 d )  4 # RAX ADD  RAX PUSH  -4 [RAX] EAX MOV ;
code: LFETCHINC, ( a -- a+8 l )  8 # RAX ADD  RAX PUSH  -8 [RAX] RAX MOV ;
code: QFETCHINC, ( a -- a+8 q )  8 # RAX ADD  RAX PUSH  -8 [RAX] RAX MOV ;
code: HFETCHINC, ( a -- a+16 h )  16 # RAX ADD  RAX PUSH  QWORD PTR -8 [RAX] PUSH  -16 [RAX] RAX MOV ;
code: OFETCHINC, ( a -- a+16 o )  16 # RAX ADD  RAX PUSH  QWORD PTR -8 [RAX] PUSH  -16 [RAX] RAX MOV ;

code: DECBFETCH, ( a -- a−1 b )  1 # RAX SUB  RAX PUSH  BYTE PTR 0 [RAX] RAX MOVSX ;
code: DECCFETCH, ( a -- a−1 c )  1 # RAX SUB  RAX PUSH  BYTE PTR 0 [RAX] RAX MOVZX ;
code: DECSFETCH, ( a -- a−2 s )  2 # RAX SUB  RAX PUSH  WORD PTR 0 [RAX] RAX MOVSX ;
code: DECWFETCH, ( a -- a−2 w )  2 # RAX SUB  RAX PUSH  WORD PTR 0 [RAX] RAX MOVZX ;
code: DECIFETCH, ( a -- a−4 i )  4 # RAX SUB  RAX PUSH  DWORD PTR 0 [RAX] RAX MOVSXD ;
code: DECDFETCH, ( a -- a−4 d )  4 # RAX SUB  RAX PUSH  0 [RAX] EAX MOV ;
code: DECLFETCH, ( a -- a−8 l )  8 # RAX SUB  RAX PUSH  0 [RAX] RAX MOV ;
code: DECQFETCH, ( a -- a−8 q )  8 # RAX SUB  RAX PUSH  0 [RAX] RAX MOV ;
code: DECHFETCH, ( a -- a−16 h )  16 # RAX SUB  RAX PUSH  QWORD PTR 8 [RAX] PUSH  0 [RAX] RAX MOV ;
code: DECOFETCH, ( a -- a−16 o )  16 # RAX SUB  RAX PUSH  QWORD PTR 8 [RAX] PUSH  0 [RAX] RAX MOV ;

code: BXCHG, ( b a -- b' a )  0 [RSP] RDX MOV  DL 0 [RAX] XCHG  DL RCX MOVSX  RCX 0 [RSP] MOV ;
code: CXCHG, ( c a -- c' a )  0 [RSP] RDX MOV  DL 0 [RAX] XCHG  DL RCX MOVZX  RCX 0 [RSP] MOV ;
code: SXCHG, ( s a -- s' a )  0 [RSP] RDX MOV  DX 0 [RAX] XCHG  DX RCX MOVSX  RCX 0 [RSP] MOV ;
code: WXCHG, ( s a -- s' a )  0 [RSP] RDX MOV  DX 0 [RAX] XCHG  DX RCX MOVZX  RCX 0 [RSP] MOV ;
code: IXCHG, ( i a -- i' a )  0 [RSP] RDX MOV  EDX 0 [RAX] XCHG  EDX RDX MOVSXD  RDX 0 [RSP] MOV ;
code: DXCHG, ( d a -- d' a )  0 [RSP] RDX MOV  EDX 0 [RAX] XCHG  EDX 0 [RSP] MOV ;
code: LXCHG, ( l a -- l' a )  0 [RSP] RDX MOV  RDX 0 [RAX] XCHG  RDX 0 [RSP] MOV ;
code: QXCHG, ( q a -- q' a )  0 [RSP] RDX MOV  RDX 0 [RAX] XCHG  RDX 0 [RSP] MOV ;
code: HXCHG, ( h a -- h' a )
  0 [RSP] RDX MOV  8 [RSP] RCX MOV  RDX 0 [RAX] XCHG  RCX 8 [RSP] XCHG  RDX 0 [RSP] MOV  RCX 8 [RSP] MOV ;
code: OXCHG, ( o a -- o' a )
  0 [RSP] RDX MOV  8 [RSP] RCX MOV  RDX 0 [RAX] XCHG  RCX 8 [RSP] XCHG  RDX 0 [RSP] MOV  RCX 8 [RSP] MOV ;

code: #USTORE, ( u a # -- )  EAX ECX MOV  RAX POP  RDX POP  FOR  DL 0 [RAX] MOV  8 # RDX SHR  1 # RAX ADD  NEXT  RESTORE, ;
code: #NSTORE, ( n a # -- )  EAX ECX MOV  RAX POP  RDX POP  FOR  DL 0 [RAX] MOV  8 # RDX SAR  1 # RAX ADD  NEXT  RESTORE, ;
code: #UFETCH, ( a # -- u )  EAX ECX MOV  RDX POP  RCX DEC  EAX EAX XOR  0< UNLESS
  0 [RCX] [RDX] RDX LEA  BYTE PTR 0 [RDX] EAX MOVZX  BEGIN  FOR  1 # RDX SUB  8 # RAX SHL  0 [RDX] AL MOV  NEXT  THEN ;
code: #NFETCH, ( a # -- u )  EAX ECX MOV  RDX POP  RCX DEC  EAX EAX XOR  0< UNLESS
  0 [RCX] [RDX] RDX LEA  BYTE PTR 0 [RDX] RAX MOVSX  BEGIN  FOR  1 # RDX SUB  8 # RAX SHL  0 [RDX] AL MOV  NEXT  THEN ;



=== Arithmetic Operations ===

--- Overflow Traps ---

code: TRAPOV, ( -- )  INTO ;
code: TRAPCY, ( -- )  CY IFEVER  4 # INT  THEN ;
code: TRAPEZ, ( -- )  0< IFEVER  5 # INT  THEN ;

--- Stack Arithmetics ---

code: PLUS, ( n1 n2 -- n1+n2 )  RAX 0 [RSP] ADD  RESTORE, ;
code: MINUS, ( n1 n2 -- n1−n2 )  RAX 0 [RSP] SUB  RESTORE, ;
code: RMINUS, ( n1 n2 -- n2−n1 )  RDX POP  RDX RAX SUB ;
code: TIMES, ( n1 n2 -- n1×n2 )  RDX POP  RDX IMUL ;
code: UTIMES, ( u1 u2 -- u1×u2 )  RDX POP  RDX MUL ;
code: THROUGH, ( n1 n2 -- n1÷n2 )  RAX RCX MOV  RAX POP  CQO  RCX IDIV ;
code: UTHROUGH, ( u1 u2 -- u1÷u2 )  RAX RCX MOV  RAX POP  RDX RDX XOR  RCX DIV ;
code: RTHROUGH, ( n1 n2 -- n2÷n1 )  RCX POP  CQO  RCX IDIV ;
code: URTHROUGH, ( u1 u2 -- u2÷u1 )  RCX POP  RDX RDX XOR  RCX DIV ;
code: MODULO, ( n1 n2 -- n1%n2 )  RAX RCX MOV  RAX POP  CQO  RCX IDIV  RDX RAX MOV ;
code: UMODULO, ( u1 u2 -- u1%u2 )  RAX RCX MOV  RAX POP  RDX RDX XOR  RCX DIV  RDX RAX MOV ;
code: RMODULO, ( n1 n2 -- n2%n1 )  RCX POP  CQO  RCX IDIV  RDX RAX MOV ;
code: URMODULO, ( u1 u2 -- u2%u1 )  RCX POP  RDX RDX XOR  RCX DIV  RDX RAX MOV ;
code: MODDIV, ( n1 n2 -- n1%n2 n1÷n2 )  RAX RCX MOV  RAX POP  CQO  RCX IDIV  RDX PUSH ;
code: UMODDIV, ( u1 u2 -- u1%u2 u1÷u2 )  RAX RCX MOV  RAX POP  RDX RDX XOR  RCX DIV  RDX PUSH ;
code: RMODDIV, ( n1 n2 -- n2%n1 n2÷n1 )  RCX POP  CQO  RCX IDIV  RDX PUSH ;
code: URMODDIV, ( u1 u2 -- u2%u1 u2÷u1 )  RCX POP  RDX RDX XOR  RCX DIV  RDX PUSH ;
code: TIMESPLUS, ( n3 n2 n1 -- n3+n2×n1 )  RDX POP  RDX IMUL  RDX POP  RDX RAX ADD ;
code: UTIMESPLUS, ( u3 u2 u1 -- u3+u2×u1 )  RDX POP  RDX MUL  RDX POP  RDX RAX ADD ;
code: TIMESBY, ( n3 n2 n1 -- n3×n2÷n1 )  RAX 8 [RSP] XCHG  RCX POP  RCX IMUL  RCX POP  RCX IDIV ;
code: UTIMESBY, ( u3 u2 u1 -- u3×u2÷u1 )  RAX 8 [RSP] XCHG  RCX POP  RCX MUL  RCX POP  RCX DIV ;

code: INCS, ( x2 x1 -- x2+1 x1 )  1 # QWORD PTR 0 [RSP] ADD ;
code: ADV, ( a # u -- a+u #−u )  RAX 8 [RSP] ADD  RAX 0 [RSP] SUB  RESTORE, ;
code: ADV1, ( a # -- a+1 #−1 )  1 # QWORD PTR 0 [RSP] ADD  1 # RAX SUB ;
code: GETCHAR, ( a # -- a+1 #−1 c )
  0 [RSP] RDX MOV  RAX PUSH  1 # QWORD PTR 0 [RSP] SUB  DL RAX MOVZX  1 # QWORD PTR CELL [RSP] ADD ;

code: NEG, ( n1 -- −n1 )  RAX NEG ;
code: ABS, ( n1 -- |n1| )  RAX RAX TEST  0< IFEVER  RAX NEG  THEN ;
code: MIN2, ( n1 n2 -- n1|n2 )  RDX POP  RAX RDX CMP  < IF  RDX RAX MOV  THEN ;
code: UMIN2, ( u1 u2 -- u1|u2 )  RDX POP  RAX RDX CMP  U< IF  RDX RAX MOV  THEN ;
code: MAX2, ( n1 n2 -- n1|n2 )  RDX POP  RAX RDX CMP  > IF  RDX RAX MOV  THEN ;
code: UMAX2, ( u1 u2 -- u1|u2 )  RDX POP  RAX RDX CMP  U> IF  RDX RAX MOV  THEN ;
code: ISWITHIN, ( n1 n2 n3 -- n2≤n1<n3 )
  RDX POP  RAX RCX MOV  RAX RAX XOR  0 [RSP] RDX CMP  ≤ IFLIKELY  0 [RSP] RCX CMP  > IFLIKELY  1 # RAX SUB  THEN  THEN ;
code: USIZE, ( u -- # )  RDX RDX XOR  RAX RDX XCHG  RDX RDX TEST  0= UNLESS
  1 # RAX ADD  $100 # RAX CMP  U< UNLESS  1 # RAX SHL  $10000 # RAX CMP  U< UNLESS  1 # RAX SHL  $100000000 # RAX CMP  U< UNLESS
  1 # RAX SHL  THEN  THEN  THEN  THEN ;
code: NSIZE, ( n -- # )  RDX RDX XOR  RAX RDX XCHG  RDX RDX TEST  0< IF  RAX NEG  THEN  0= UNLESS
  1 # RAX ADD  $80 # RAX CMP  U< UNLESS  1 # RAX SHL  $8000 # RAX CMP  U< UNLESS  1 # RAX SHL  $80000000 # RAX CMP  U< UNLESS
  1 # RAX SHL  THEN  THEN  THEN  THEN ;

--- Memory Arithmetics ---

code: CADD, ( c a -- )  RDX POP  DL 0 [RAX] ADD  RESTORE, ;
code: WADD, ( w a -- )  RDX POP  DX 0 [RAX] ADD  RESTORE, ;
code: DADD, ( d a -- )  RDX POP  EDX 0 [RAX] ADD  RESTORE, ;
code: QADD, ( q a -- )  RDX POP  RDX 0 [RAX] ADD  RESTORE, ;
code: OADD, ( o a -- )  RDX POP  RCX POP  RDX 0 [RAX] ADD  RCX 8 [RAX] ADC  RESTORE, ;

code: CSUB, ( c a -- )  RDX POP  DL 0 [RAX] SUB  RESTORE, ;
code: WSUB, ( w a -- )  RDX POP  DX 0 [RAX] SUB  RESTORE, ;
code: DSUB, ( d a -- )  RDX POP  EDX 0 [RAX] SUB  RESTORE, ;
code: QSUB, ( q a -- )  RDX POP  RDX 0 [RAX] SUB  RESTORE, ;
code: OSUB, ( o a -- )  RDX POP  RCX POP  RDX 0 [RAX] SUB  RCX 8 [RAX] SBB  RESTORE, ;



=== Logical Operations ===

--- Stack Logics ---

code: AND, ( x1 x2 -- x1^x2 )  RAX 0 [RSP] AND  RESTORE, ;
code: OR, ( x1 x2 -- x1vx2 )  RAX 0 [RSP] OR  RESTORE, ;
code: XOR, ( x1 x2 -- x1¤x2 )  RAX 0 [RSP] XOR  RESTORE, ;
code: NOT, ( x -- ¬x )  RAX NOT ;

code: BOOLAND, ( x1 x2 -- x1&x2 )  RDX POP  1 # RDX SUB  CMC  RDX RDX SBB  1 # RAX SUB  CMC  RAX RAX SBB  RDX RAX AND ;
code: BOOLOR, ( x1 x2 -- x1|x2 )  RDX POP  RDX RAX OR  1 # RAX SUB  CMC  RAX RAX SBB ;
code: BOOLXOR, ( x1 x2 -- x1⋄x2 )  RDX POP  1 # RDX SUB  CMC  RDX RDX SBB  1 # RAX SUB  CMC  RAX RAX SBB  RDX RAX XOR ;
code: BOOLNOT, ( x1 -- !x1 )  1 # RAX SUB  RAX RAX SBB ;

code: SHL, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] SHL  RESTORE, ;
code: SHR, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] SHR  RESTORE, ;
code: SAR, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] SAR  RESTORE, ;
code: ROL, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] ROL  RESTORE, ;
code: ROR, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] ROR  RESTORE, ;
code: RCL, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] RCL  RESTORE, ;
code: RCR, ( x1 # -- x2 )  AL CL MOV  CL QWORD PTR 0 [RSP] RCR  RESTORE, ;

code: BSET, ( x # -- x' )  RAX QWORD PTR 0 [RSP] BTS  RESTORE, ;
code: BCLR, ( x # -- x' )  RAX QWORD PTR 0 [RSP] BTR  RESTORE, ;
code: BCHG, ( x # -- x' )  RAX QWORD PTR 0 [RSP] BTC  RESTORE, ;
code: BTST, ( x # -- ? )  RAX QWORD PTR 0 [RSP] BT  RDX POP  RAX RAX SBB ;
code: BTSET, ( x # -- x' ? )  RAX QWORD PTR 0 [RSP] BTS  RAX RAX SBB ;
code: BTCLR, ( x # -- x' ? )  RAX QWORD PTR 0 [RSP] BTR  RAX RAX SBB ;
code: BTCHG, ( x # -- x' ? )  RAX QWORD PTR 0 [RSP] BTC  RAX RAX SBB ;
code: BTTST, ( x # -- x ? )  RAX QWORD PTR 0 [RSP] BT  RAX RAX SBB ;
code: ABTSET, ( x # -- x' ? )  LOCK  RAX QWORD PTR 0 [RSP] BTS  RAX RAX SBB ;
code: ABTCLR, ( x # -- x' ? )  LOCK  RAX QWORD PTR 0 [RSP] BTR  RAX RAX SBB ;
code: ABTCHG, ( x # -- x' ? )  LOCK  RAX QWORD PTR 0 [RSP] BTC  RAX RAX SBB ;

code: BSF1, ( u -- #|-1 )  RAX RAX BSF  0= IF  STC  RAX RAX SBB  THEN ;
code: BSR1, ( u -- #|-1 )  RAX RAX BSR  0= IF  STC  RAX RAX SBB  THEN ;
code: BSF0, ( u -- #|-1 )  RAX NOT  RAX RAX BSF  0= IF  STC  RAX RAX SBB  THEN ;
code: BSR0, ( u -- #|-1 )  RAX NOT  RAX RAX BSR  0= IF  STC  RAX RAX SBB  THEN ;
code: CBSF0, ( c -- #|-1 )  AL RDX MOVZX  RDX NOT  RDX RAX BSF  0= IF  STC  RAX RAX SBB  THEN ;
code: CBSR0, ( c -- #|-1 )  AL RDX MOVZX  RDX NOT  RDX RAX BSR  0= IF  STC  RAX RAX SBB  THEN ;

code: BSF1AT, ( a #1 -- #2|-1 )  RAX RCX MOV  EDX EDX XOR  0 [RSP] RSI XCHG  RDI PUSH
  FOR  0 [RSI] RAX MOV  CELL # RSI ADD  RAX RDI BSF  0= IF  64 [RDX] RDX LEA  THEN  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;
code: CBSF1AT, ( a #1 -- #2|-1 )  RAX RCX MOV  RDX RDX XOR  0 [RSP] RSI XCHG  RDX RAX MOV  RDI PUSH
  FOR  0 [RSI] AL MOV  1 # RSI ADD  RAX RDI BSF  0= IF  8 [RDX] RDX LEA  THEN  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN ;
code: BSR1AT, ( a #1 -- #2|-1 )  RAX RCX MOV  0 [RSP] RSI XCHG  EAX EAX XOR  RDI PUSH  0 [RSI] [RCX] *8 RSI LEA
  RCX RDX MOV  6 # RDX SHL  FOR  CELL # RSI SUB  -64 [RDX] RDX LEA  0 [RSI] RDI BSR  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;
code: CBSR1AT, ( a #1 -- #2|-1 )  RAX RCX MOV  0 [RSP] RSI XCHG  RDI PUSH  0 [RSI] [RCX] RSI LEA
  0 [RCX] *8 RDX LEA  FOR  1 # RSI SUB  -8 [RDX] RDX LEA  BYTE PTR 0 [RSI] RAX MOVZX  RAX RDI BSR  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;
code: BSF0AT, ( a #1 -- #2|-1 )  RAX RCX MOV  0 [RSP] RSI XCHG  EDX EDX XOR  RDI PUSH
  FOR  0 [RSI] RAX MOV  CELL # RSI ADD  RAX NOT  RAX RDI BSF  0= IF  64 [RDX] RDX LEA  THEN  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;
code: CBSF0AT, ( a #1 -- #2|-1 )  RAX RCX MOV  0 [RSP] RSI XCHG  EDX EDX XOR  RDX RAX MOV  RDI PUSH
  FOR  BYTE PTR 0 [RSI] RAX MOVZX  1 # RSI ADD  RAX NOT  RAX RDI BSF  0= IF  8 [RDX] RDX LEA  THEN  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;
code: BSR0AT, ( a #1 -- #2|-1 )  RAX RCX MOV  0 [RSP] RSI XCHG  0 [RSI] [RCX] *8 RSI LEA  RDI PUSH
  RCX RDX MOV  6 # RDX SHL  FOR  0 [RSI] RAX MOV  CELL # RSI ADD  RAX NOT  -64 [RDX] RDX LEA  RAX RDI BSR  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;
code: CBSR0AT, ( a #1 -- #2|-1 )  RAX RCX MOV  0 [RSP] RSI XCHG  0 [RCX] *8 RDX LEA  0 [RCX] [RSI] RSI LEA  RDI PUSH
  FOR  1 # RSI SUB  -8 [RDX] RDX LEA  BYTE PTR 0 [RSI] RAX MOVZX  RAX NOT  RAX RDI BSR  0= ?NEXT
  0= IF  STC  RAX RAX SBB  ELSE  RDX RAX MOV  RDI RAX ADD  THEN  RDI POP  RSI POP ;

--- Memory Logics ---

code: BSETAT, ( a # -- )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BTS  RESTORE, ;
code: BCLRAT, ( a # -- )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BTR  RESTORE, ;
code: BCHGAT, ( a # -- )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BTC  RESTORE, ;
code: BTSTAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BT  RAX RAX SBB ;
code: BTSETAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BTS  RAX RAX SBB ;
code: BTCLRAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BTR  RAX RAX SBB ;
code: BTCHGAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  RCX 0 [RDX] [RAX] BTC  RAX RAX SBB ;
code: ABTSETAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  LOCK  RCX 0 [RDX] [RAX] BTS  RAX RAX SBB ;
code: ABTCLRAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  LOCK  RCX 0 [RDX] [RAX] BTR  RAX RAX SBB ;
code: ABTCHGAT, ( a # -- ? )  RAX RCX MOV  7 # RCX AND  CELL% # RAX SHR  RDX POP  LOCK  RCX 0 [RDX] [RAX] BTC  RAX RAX SBB ;

--- Comparison ---

------ these are more effective, but very hard to combine — abandoned in favor of the replacements below
code: 'ISZERO, ( x -- ? )  1 # RAX SUB  CMC  RAX RAX SBB ;
code: 'ISNOTZERO, ( x -- ? )  1 # RAX SUB  RAX RAX SBB ;
code: 'ISNEGATIVE, ( x -- ? )  1 # RAX SHL  RAX RAX SBB ;
code: 'ISPOSITIVE, ( x -- ? )  AL 0≤ ?SET  1 # AL SUB  AL RAX MOVSX ;
code: 'ISNOTNEGATIVE, ( x -- ? )  1 # RAX SHL  CMC  RAX RAX SBB ;
code: 'ISNOTPOSITIVE, ( x -- ? )  AL 0> ?SET  1 # AL SUB  AL RAX MOVSX ;

code: 'ISEQUAL, ( x y -- ? )  RDX POP  RDX RAX SUB  1 # RAX SUB  CMC  RAX RAX SBB ;
code: 'ISINIQUAL, ( x y -- ? )  RDX POP  RDX RAX SUB  1 # RAX SUB  RAX RAX SBB ;
code: 'ISLESS, ( n1 n2 -- ? )  RDX POP  RDX RAX SUB  1 # RAX SHL  RAX RAX SBB ;
code: 'ISBELOW, ( u1 u2 -- ? )  RDX POP  RDX RAX SUB  RAX RAX SBB ;
code: 'ISGREATER, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  AL ≤ ?SET  1 # AL SUB  AL RAX MOVSX ;
code: 'ISABOVE, ( u1 u2 -- ? )  RDX POP  RDX RAX CMP  AL U≤ ?SET  1 # AL SUB  AL RAX MOVSX ;
code: 'ISNOTGREATER, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  AL > ?SET  1 # AL SUB  AL RAX MOVSX ;
code: 'ISNOTABOVE, ( u1 u2 -- ? )  RDX POP  RDX RAX CMP  AL U> ?SET  1 # AL SUB  AL RAX MOVSX ;
code: 'ISNOTLESS, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  AL < ?SET  1 # AL SUB  AL RAX MOVSX ;
code: 'ISNOTBELOW, ( u1 u2 -- ? )  RDX POP  RDX RAX SUB  CMC  RAX RAX SBB ;
------

code: ISZERO, ( x -- ? )  RAX RAX TEST  DL 0≠ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTZERO, ( x -- ? )  RAX RAX TEST  DL 0= ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNEGATIVE, ( x -- ? )  RAX RAX TEST  DL 0≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTNEGATIVE, ( x -- ? )  RAX RAX TEST  DL 0< ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISPOSITIVE, ( x -- ? )  RAX RAX TEST  DL 0≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTPOSITIVE, ( x -- ? )  RAX RAX TEST  DL 0> ?SET  1 # DL SUB  DL RAX MOVSX ;

code: ISEQUAL, ( x1 x2 -- ? )  RDX POP  RDX RAX CMP  DL ≠ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISINIQUAL, ( x1 x2 -- ? )  RDX POP  RDX RAX CMP  DL = ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISLESS, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  DL ≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTLESS, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  DL < ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISGREATER, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  DL ≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTGREATER, ( n1 n2 -- ? )  RDX POP  RDX RAX CMP  DL > ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISBELOW, ( u1 u2 -- ? )  RDX POP  RDX RAX CMP  DL U≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTBELOW, ( u1 u2 -- ? )  RDX POP  RDX RAX CMP  DL U< ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISABOVE, ( u1 u2 -- ? )  RDX POP  RDX RAX CMP  DL U≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTABOVE, ( u1 u2 -- ? )  RDX POP  RDX RAX CMP  DL U> ?SET  1 # DL SUB  DL RAX MOVSX ;

code: ISZERODUP, ( x -- x ? )  SAVE,  RAX RAX TEST  DL 0≠ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTZERODUP, ( x -- x ? )  SAVE,  RAX RAX TEST  DL 0= ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNEGATIVEDUP, ( x -- x? )  SAVE,  RAX RAX TEST  DL 0≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTNEGATIVEDUP, ( x -- x ? )  SAVE,  RAX RAX TEST  DL 0< ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISPOSITIVEDUP, ( x -- x ? )  SAVE,  RAX RAX TEST  DL 0≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTPOSITIVEDUP, ( x -- x ? )  SAVE,  RAX RAX TEST  DL 0> ?SET  1 # DL SUB  DL RAX MOVSX ;

code: ISEQUALDUP, ( x1 x2 -- ? )  0 [RSP] RAX CMP  DL ≠ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISINIQUALDUP, ( x1 x2 -- ? )  0 [RSP] RAX CMP  DL = ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISLESSDUP, ( n1 n2 -- ? )  0 [RSP] RAX CMP  DL ≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTLESSDUP, ( n1 n2 -- ? )  0 [RSP] RAX CMP  DL < ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISGREATERDUP, ( n1 n2 -- ? )  0 [RSP] RAX CMP  DL ≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTGREATERDUP, ( n1 n2 -- ? )  0 [RSP] RAX CMP  DL > ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISBELOWDUP, ( u1 u2 -- ? )  0 [RSP] RAX CMP  DL U≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTBELOWDUP, ( u1 u2 -- ? )  0 [RSP] RAX CMP  DL U< ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISABOVEDUP, ( u1 u2 -- ? )  0 [RSP] RAX CMP  DL U≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTABOVEDUP, ( u1 u2 -- ? )  0 [RSP] RAX CMP  DL U> ?SET  1 # DL SUB  DL RAX MOVSX ;

code: ISEQUAL2DUP, ( x1 x2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL ≠ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISINIQUAL2DUP, ( x1 x2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL = ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISLESS2DUP, ( n1 n2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL ≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTLESS2DUP, ( n1 n2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL < ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISGREATER2DUP, ( n1 n2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL ≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTGREATER2DUP, ( n1 n2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL > ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISBELOW2DUP, ( u1 u2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL U≥ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTBELOW2DUP, ( u1 u2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL U< ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISABOVE2DUP, ( u1 u2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL U≤ ?SET  1 # DL SUB  DL RAX MOVSX ;
code: ISNOTABOVE2DUP, ( u1 u2 -- ? )  SAVE,  CELL [RSP] RAX CMP  DL U> ?SET  1 # DL SUB  DL RAX MOVSX ;



=== Block Operations ===

--- Block Fill ---

code: CFILL, ( a # c -- )  RCX POP  0 [RSP] RDI XCHG  CLD  REP BYTE PTR STOS  RDI POP  RESTORE, ;  inline
code: WFILL, ( a # w -- )  RCX POP  0 [RSP] RDI XCHG  CLD  REP WORD PTR STOS  RDI POP  RESTORE, ;  inline
code: DFILL, ( a # d -- )  RCX POP  0 [RSP] RDI XCHG  CLD  REP DWORD PTR STOS  RDI POP  RESTORE, ;  inline
code: QFILL, ( a # q -- )  RCX POP  0 [RSP] RDI XCHG  CLD  REP QWORD PTR STOS  RDI POP  RESTORE, ;  inline
code: OFILL, ( a # o -- )  RDX POP  RCX POP  0 [RSP] RDI XCHG
  FOR  RAX 0 [RDI] MOV  RDX 8 [RDI] MOV  16 [RDI] RDI LEA  NEXT  RDI POP  RESTORE, ;  inline

--- Block Search ---

code: CFIND, ( a # c -- u )  RCX POP  0 [RSP] RSI XCHG  RCX RDX MOV
  FOR  AL 0 [RSI] CMP  1 [RSI] RSI LEA  ≠ ?NEXT  RDX RCX ≠ ?MOV  RCX RDX SUB  RSI POP  RDX RAX MOV ;
code: WFIND, ( a # w -- u )  RCX POP  0 [RSP] RSI XCHG  RCX RDX MOV
  FOR  AX 0 [RSI] CMP  2 [RSI] RSI LEA  ≠ ?NEXT  RDX RCX ≠ ?MOV  RCX RDX SUB  RSI POP  RDX RAX MOV ;
code: DFIND, ( a # d -- u )  RCX POP  0 [RSP] RSI XCHG  RCX RDX MOV
  FOR  EAX 0 [RSI] CMP  4 [RSI] RSI LEA  ≠ ?NEXT  RDX RCX ≠ ?MOV  RCX RDX SUB  RSI POP  RDX RAX MOV ;
code: QFIND, ( a # q -- u )  RCX POP  0 [RSP] RSI XCHG  RCX RDX MOV
  FOR  RAX 0 [RSI] CMP  8 [RSI] RSI LEA  ≠ ?NEXT  RDX RCX ≠ ?MOV  RCX RDX SUB  RDX RAX MOV ;
code: OFIND, ( a # o -- u )  2 CELLS [RSP] RDI XCHG  CELL [RSP] RCX XCHG  0 [RSP] RSI XCHG  RCX RDX MOV
  FOR  RAX 0 [RSI] CMP  16 [RSI] RSI LEA  = IF  RDI 8 [RSI] CMP  THEN  ≠ ?NEXT  RDX RCX ≠ ?MOV  RSI POP  RCX RDX SUB
  RCX POP  RDX RAX MOV  RDI POP ;

--- Block Move ---

code: CMOVE, ( sa ta # -- )  RAX RCX MOV  CELL [RSP] RDI XCHG  0 [RSP] RSI XCHG  CLD
  RSI RDI CMP  U> IFEVER  -1 [RSI] [RCX] RSI LEA  -1 [RDI] [RCX] RDI LEA  STD  THEN  REP BYTE PTR MOVS
  RSI POP  RDI POP  RESTORE, ;
code: WMOVE, ( sa ta # -- )  RAX RCX MOV  CELL [RSP] RDI XCHG  0 [RSP] RSI XCHG  CLD
  RSI RDI CMP  U> IFEVER  -2 [RSI] [RCX] RSI LEA  -2 [RDI] [RCX] RDI LEA  STD  THEN  REP WORD PTR MOVS
  RSI POP  RDI POP  RESTORE, ;
code: DMOVE, ( sa ta # -- )  RAX RCX MOV  CELL [RSP] RDI XCHG  0 [RSP] RSI XCHG  CLD
  RSI RDI CMP  U> IFEVER  -4 [RSI] [RCX] RSI LEA  -4 [RDI] [RCX] RDI LEA  STD  THEN  REP DWORD PTR MOVS
  RSI POP  RDI POP  RESTORE, ;
code: QMOVE, ( sa ta # -- )  RAX RCX MOV  CELL [RSP] RDI XCHG  0 [RSP] RSI XCHG  CLD
  RSI RDI CMP  U> IFEVER  -8 [RSI] [RCX] RSI LEA  -8 [RDI] [RCX] RDI LEA  STD  THEN  REP QWORD PTR MOVS
  RSI POP  RDI POP  RESTORE, ;



=== Real (or rather floating point) Numbers ===

--- Constants ---

code: 0.0, ( -- F: -- 0.0 )  FLD0 ;
code: 1.0, ( -- F: -- 1.0 )  FLD1 ;
code: M1.0, ( -- F: -- −1.0 )  FLD1 FCHS ;
code: PI, ( -- F: -- π )  FLDPI ;

--- Memory Operations ---

code: FSTORE, ( a -- F: r -- )  QWORD PTR 0 [RAX] FSTP  RESTORE, ;
code: FFETCH, ( a -- F: -- r )  QWORD PTR 0 [RAX] FLD  RESTORE, ;


=== UTF8 ===

code: GETUC, ( a # -- a' #' uc|-1 )                   ( Next UTF-8 character uc from buffer, or -1 on error or end-of-buffer )
  ( RSI = a', RDX = #', RBX = c, RCX = shift, AH, NC = valid? )
  RAX RDX MOV  0 [RSP] RSI XCHG  RBX PUSH  RAX RAX TEST  STC  0≠ IF
    0 [RSI] AL MOV  1 # RDX SUB  1 # RSI ADD  AL RAX MOVSX  7 # RAX BT  CY IF
      RAX RBX MOV  RAX NOT  RAX RCX BSR  ( valid RCX: 3, 4, 5 )  STC  0= UNLESS
        3 # RCX CMP  U< UNLESS
          6 # RCX CMP  U< IF
            AH AH XOR  RCX NEG  BL AL MOV  8 # RCX ADD  CL AL SHL  CL AL SHR  AL BL MOV  2 # RCX SUB  BEGIN
              RDX RDX TEST  0≠ IF
                0 [RSI] AL MOV  1 # RSI ADD  1 # RDX SUB  7 # RAX BTC
                %1000000 # AL CMP  U> IFEVER  1 # AH MOV  ELSE  6 # RBX SHL  RAX RBX ADD  THEN  THEN
              1 # RCX SUB  0= UNTIL
            1 # AH SHR  THEN
          THEN
        THEN
      THEN
    THEN
  RSI 0 [RSP] XCHG  RBX RAX MOV  RBX POP  RDX PUSH  CY IF  RAX RAX SBB  THEN ;

code: INCUC, ( a -- ? )                               ( increment length indicator, report if failed due to overflow )
;


=== Execution ===

code: EXECUTE, ( cfa -- )  RAX RDX MOV  RAX POP  RDX CALL ;
code: NOP, ( -- )  NOP ;


vocabulary;
