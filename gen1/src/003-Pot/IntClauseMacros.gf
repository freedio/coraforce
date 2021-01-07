\ IntClauses vocabulary for GForth Linux-4.19 amd64

vocabulary IntClauseMacros
also IntClauseMacros definitions
also Forcembler

: [DEBUGLIT],  c" cr" compile  1 ADP+  RAX PUSH  1 ADP-  # RAX MOV  c" ." compile
  RAX PUSH  $3A # RAX MOV  c" emit" compile  c" space" compile  c" .s" compile  c" space" compile ;

: [UNIP],  CELLS # RSP ADD ;
: [UDROP],  1- [UNIP],  RAX POP ;
: [UPICK],  1 ADP+  RAX PUSH  1 ADP-  CELLS [RSP] RAX MOV ;

: [PLUS],  # RAX ADD ;
: [MINUS],  # RAX SUB ;
: [LSHIFT],  # RAX SHL ;
: [RSHIFT],  # RAX SAR ;
: [URSHIFT],  # RAX SHR ;
: [LROT],  # RAX ROL ;
: [RROT],  # RAX ROR ;
: [AND],  # RAX AND ;
: [OR],  # RAX OR ;
: [XOR],  # RAX XOR ;
: [ANDN],  invert # RAX AND ;

: [BT],  # RAX BT  RAX PUSH  RAX RAX SBB ;
: [BTS],  # RAX BTS  RAX PUSH  RAX RAX SBB ;
: [BTR],  # RAX BTR  RAX PUSH  RAX RAX SBB ;
: [BTC],  # RAX BTC  RAX PUSH  RAX RAX SBB ;
: [BS],  # RAX BTS ;
: [BR],  # RAX BTR ;
: [BC],  # RAX BTC ;
: [BIT],  1 swap << # RAX MOV ;

: [CSTORE],  # BYTE PTR 0 [RAX] MOV  DROP, ;
: [WSTORE],  # WORD PTR 0 [RAX] MOV  DROP, ;
: [DSTORE],  # DWORD PTR 0 [RAX] MOV  DROP, ;
: [QSTORE],  # QWORD PTR 0 [RAX] MOV  DROP, ;
: [CSTOREINC],  # BYTE PTR 0 [RAX] MOV  RAX INC ;
: [WSTOREINC],  # WORD PTR 0 [RAX] MOV  2 # RAX ADD ;
: [DSTOREINC],  # DWORD PTR 0 [RAX] MOV  4 # RAX ADD ;
: [QSTOREINC],  # QWORD PTR 0 [RAX] MOV  8 # RAX ADD ;

: [ADDC],  # BYTE PTR 0 [RAX] ADD  DROP, ;
: [ADDW],  # WORD PTR 0 [RAX] ADD  DROP, ;
: [ADDD],  # DWORD PTR 0 [RAX] ADD  DROP, ;
: [ADDQ],  # QWORD PTR 0 [RAX] ADD  DROP, ;
: [SUBC],  # BYTE PTR 0 [RAX] SUB  DROP, ;
: [SUBW],  # WORD PTR 0 [RAX] SUB  DROP, ;
: [SUBD],  # DWORD PTR 0 [RAX] SUB  DROP, ;
: [SUBQ],  # QWORD PTR 0 [RAX] SUB  DROP, ;
: [FETCHSUBQ],  negate # RDX MOV  0 [RAX] RDX XCHG  RDX 0 [RAX] ADD  RDX RAX MOV ;
: [BSAL],  # BYTE PTR 0 [RAX] SHL  DROP, ;
: [BSAR],  # BYTE PTR 0 [RAX] SAR  DROP, ;
: [CSHL],  # BYTE PTR 0 [RAX] SHL  DROP, ;
: [CSHR],  # BYTE PTR 0 [RAX] SHR  DROP, ;
: [SSAL],  # WORD PTR 0 [RAX] SHL  DROP, ;
: [SSAR],  # WORD PTR 0 [RAX] SAR  DROP, ;
: [WSHL],  # WORD PTR 0 [RAX] SHL  DROP, ;
: [WSHR],  # WORD PTR 0 [RAX] SHR  DROP, ;
: [ISAL],  # DWORD PTR 0 [RAX] SHL  DROP, ;
: [ISAR],  # DWORD PTR 0 [RAX] SAR  DROP, ;
: [DSHL],  # DWORD PTR 0 [RAX] SHL  DROP, ;
: [DSHR],  # DWORD PTR 0 [RAX] SHR  DROP, ;
: [LSAL],  # QWORD PTR 0 [RAX] SHL  DROP, ;
: [LSAR],  # QWORD PTR 0 [RAX] SAR  DROP, ;
: [QSHL],  # QWORD PTR 0 [RAX] SHL  DROP, ;
: [QSHR],  # QWORD PTR 0 [RAX] SHR  DROP, ;
: [VSAL],
  # CL MOV  0 [RAX] RDX MOV  CL RDX QWORD PTR CELL [RAX] SHLD  CL QWORD PTR 0 [RAX] SAL  DROP, ;
: [VSAR],
  # CL MOV  CELL [RAX] RDX MOV  CL RDX QWORD PTR 0 [RAX] SHRD  CL QWORD PTR CELL [RAX] SAR  DROP, ;
: [OSHL],
  # CL MOV  0 [RAX] RDX MOV  CL RDX QWORD PTR CELL [RAX] SHLD  CL QWORD PTR 0 [RAX] SHL  DROP, ;
: [OSHR],
  # CL MOV  CELL [RAX] RDX MOV  CL RDX QWORD PTR 0 [RAX] SHRD  CL QWORD PTR CELL [RAX] SHR  DROP, ;
: [ANDC],  # BYTE PTR 0 [RAX] AND  DROP, ;
: [ANDW],  # WORD PTR 0 [RAX] AND  DROP, ;
: [ANDD],  # DWORD PTR 0 [RAX] AND  DROP, ;
: [ANDQ],  # QWORD PTR 0 [RAX] AND  DROP, ;
: [ORC],  # BYTE PTR 0 [RAX] OR  DROP, ;
: [ORW],  # WORD PTR 0 [RAX] OR  DROP, ;
: [ORD],  # DWORD PTR 0 [RAX] OR  DROP, ;
: [ORQ],  # QWORD PTR 0 [RAX] OR  DROP, ;
: [XORC],  # BYTE PTR 0 [RAX] XOR  DROP, ;
: [XORW],  # WORD PTR 0 [RAX] XOR  DROP, ;
: [XORD],  # DWORD PTR 0 [RAX] XOR  DROP, ;
: [XORQ],  # QWORD PTR 0 [RAX] XOR  DROP, ;

: [BTAT],  # QWORD PTR 0 [RAX] BT  RAX RAX SBB ;
: [BTSAT],  # QWORD PTR 0 [RAX] BTS  RAX RAX SBB ;
: [BTRAT],  # QWORD PTR 0 [RAX] BTR  RAX RAX SBB ;
: [BTCAT],  # QWORD PTR 0 [RAX] BTC  RAX RAX SBB ;
: [BSAT],  # QWORD PTR 0 [RAX] BTS  DROP, ;
: [BRAT],  # QWORD PTR 0 [RAX] BTR  DROP, ;
: [BCAT],  # QWORD PTR 0 [RAX] BTC  DROP, ;

: [CELLS],  1 ADP+  RAX PUSH  1 ADP-  cells # RAX MOV ;
: [CELLSPLUS],  cells # RAX ADD ;
: [ADVANCE],  1 ADP+  dup # RAX SUB  1 ADP-  # QWORD PTR 0 [RSP] ADD ;

------
: [ISEQUAL],  # RAX SUB  setCurrent  ISZERO,  ['] ?ISEQUAL#, CONDITION ! ;
: [ISNOTEQUAL],  # RAX SUB  setCurrent  ISNOTZERO,  ['] ?ISNOTEQUAL#, CONDITION ! ;
: [ISLESS],  # RAX SUB  setCurrent  ISNEGATIVE,  ['] ?ISLESS#, CONDITION ! ;
: [ISNOTLESS],  # RAX SUB  setCurrent  ISNOTNEGATIVE,  ['] ?ISNOTLESS#, CONDITION ! ;
: [ISGREATER],  # RAX SUB  setCurrent  ISPOSITIVE,  ['] ?ISGREATER#, CONDITION ! ;
: [ISNOTGREATER],  # RAX SUB  setCurrent  ISNOTPOSITIVE,  ['] ?ISNOTGREATER#, CONDITION ! ;
: [ISBELOW],  # RAX SUB  setCurrent  RAX RAX SBB  ['] ?ISBELOW#, CONDITION ! ;
: [ISNOTBELOW],  # RAX SUB  setCurrent  CMC  RAX RAX SBB  ['] ?ISNOTBELOW#, CONDITION ! ;
: [ISABOVE],  # RAX SUB  setCurrent  AL U> ?SET  AL NEG  AL RAX MOVSX  ['] ?ISABOVE#, CONDITION ! ;
: [ISNOTABOVE],  # RAX SUB  setCurrent  AL U≤ ?SET  AL NEG  AL RAX MOVSX  ['] ?ISNOTABOVE#, CONDITION ! ;
------

: [IFEQUAL],  # RAX CMP  DROP,  = IF ;
: [IFNOTEQUAL],  # RAX CMP  DROP,  ≠ IF ;
: [IFLESS],  # RAX CMP  DROP,  < IF ;
: [IFNOTLESS],  # RAX CMP  DROP,  ≥ IF ;
: [IFGREATER],  # RAX CMP  DROP,  > IF ;
: [IFNOTGREATER],  # RAX CMP  DROP,  ≤ IF ;
: [IFBELOW],  # RAX CMP  DROP,  U< IF ;
: [IFNOTBELOW],  # RAX CMP  DROP,  U≥ IF ;
: [IFABOVE],  # RAX CMP  DROP,  U> IF ;
: [IFNOTABOVE],  # RAX CMP  DROP,  = IF ;
: [DUPIFEQUAL],  # RAX CMP  = IF ;
: [DUPIFNOTEQUAL],  # RAX CMP  ≠ IF ;
: [DUPIFLESS],  # RAX CMP  < IF ;
: [DUPIFNOTLESS],  # RAX CMP  ≥ IF ;
: [DUPIFGREATER],  # RAX CMP  > IF ;
: [DUPIFNOTGREATER],  # RAX CMP  ≤ IF ;
: [DUPIFBELOW],  # RAX CMP  U< IF ;
: [DUPIFNOTBELOW],  # RAX CMP  U≥ IF ;
: [DUPIFABOVE],  # RAX CMP  U> IF ;
: [DUPIFNOTABOVE],  # RAX CMP  = IF ;

: [IFEVEREQUAL],  # RAX CMP  DROP,  = IFEVER ;
: [IFEVERNOTEQUAL],  # RAX CMP  DROP,  ≠ IFEVER ;
: [IFEVERLESS],  # RAX CMP  DROP,  < IFEVER ;
: [IFEVERNOTLESS],  # RAX CMP  DROP,  ≥ IFEVER ;
: [IFEVERGREATER],  # RAX CMP  DROP,  > IFEVER ;
: [IFEVERNOTGREATER],  # RAX CMP  DROP,  ≤ IFEVER ;
: [IFEVERBELOW],  # RAX CMP  DROP,  U< IFEVER ;
: [IFEVERNOTBELOW],  # RAX CMP  DROP,  U≥ IFEVER ;
: [IFEVERABOVE],  # RAX CMP  DROP,  U> IFEVER ;
: [IFEVERNOTABOVE],  # RAX CMP  DROP,  = IFEVER ;
: [DUPIFEVEREQUAL],  # RAX CMP  = IFEVER ;
: [DUPIFEVERNOTEQUAL],  # RAX CMP  ≠ IFEVER ;
: [DUPIFEVERLESS],  # RAX CMP  < IFEVER ;
: [DUPIFEVERNOTLESS],  # RAX CMP  ≥ IFEVER ;
: [DUPIFEVERGREATER],  # RAX CMP  > IFEVER ;
: [DUPIFEVERNOTGREATER],  # RAX CMP  ≤ IFEVER ;
: [DUPIFEVERBELOW],  # RAX CMP  U< IFEVER ;
: [DUPIFEVERNOTBELOW],  # RAX CMP  U≥ IFEVER ;
: [DUPIFEVERABOVE],  # RAX CMP  U> IFEVER ;
: [DUPIFEVERNOTABOVE],  # RAX CMP  = IFEVER ;

: [BTIF],  # RAX BT  CY IF ;
: [BTSIF],  # RAX BTS  CY IF ;
: [BTRIF],  # RAX BTR  CY IF ;
: [BTCIF],  # RAX BTC  CY IF ;
: [BTUNLESS],  # RAX BT  CY UNLESS ;
: [BTSUNLESS],  # RAX BTS  CY UNLESS ;
: [BTRUNLESS],  # RAX BTR  CY UNLESS ;
: [BTCUNLESS],  # RAX BTC  CY UNLESS ;

: [TIMES], ( n -- )  case
  1 of  NOP  endof
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
: [UTIMES], ( n -- )  case
  1 of  NOP  endof
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
: [THROUGH], ( n -- )  case
  1 of  NOP  endof
  2 of  1 # RAX SAR  endof
  4 of  2 # RAX SAR  endof
  8 of  3 # RAX SAR  endof
  16 of  4 # RAX SAR  endof
  32 of  5 # RAX SAR  endof
  64 of  6 # RAX SAR  endof
  128 of  7 # RAX SAR  endof
  256 of  8 # RAX SAR  endof
  512 of  9 # RAX SAR  endof
  1024 of  10 # RAX SAR  endof
  2048 of  11 # RAX SAR  endof
  4096 of  12 # RAX SAR  endof
  8192 of  13 # RAX SAR  endof
  16384 of  14 # RAX SAR  endof
  32768 of  15 # RAX SAR  endof
  65536 of  16 # RAX SAR  endof
  # RCX MOV  CQO  RCX IDIV  0 endcase ;
: [UTHROUGH], ( u -- )  case
  1 of  NOP  endof
  2 of  1 # RAX SHR  endof
  4 of  2 # RAX SHR  endof
  8 of  3 # RAX SHR  endof
  16 of  4 # RAX SHR  endof
  32 of  5 # RAX SHR  endof
  64 of  6 # RAX SHR  endof
  128 of  7 # RAX SHR  endof
  256 of  8 # RAX SHR  endof
  512 of  9 # RAX SHR  endof
  1024 of  10 # RAX SHR  endof
  2048 of  11 # RAX SHR  endof
  4096 of  12 # RAX SHR  endof
  8192 of  13 # RAX SHR  endof
  16384 of  14 # RAX SHR  endof
  32768 of  15 # RAX SHR  endof
  65536 of  16 # RAX SHR  endof
  # RCX MOV  RDX RDX XOR  RCX DIV  0 endcase ;
: [MODULO], ( n|u -- )  case
  1 of  RAX RAX XOR  endof
  2 of  1 # RAX AND  endof
  4 of  3 # RAX AND  endof
  8 of  7 # RAX AND  endof
  16 of  15 # RAX AND  endof
  32 of  31 # RAX AND  endof
  64 of  63 # RAX AND  endof
  128 of  127 # RAX AND  endof
  256 of  255 # RAX AND  endof
  512 of  511 # RAX AND  endof
  1024 of  1023 # RAX AND  endof
  2048 of  2047 # RAX AND  endof
  4096 of  4095 # RAX AND  endof
  8192 of  8191 # RAX AND  endof
  16384 of  16383 # RAX AND  endof
  32768 of  32767 # RAX AND  endof
  65536 of  65535 # RAX AND  endof
  # RCX MOV  RDX RDX XOR  RCX DIV  RDX RAX MOV  0 endcase ;
: [QUOTREM], ( u -- )  case
  1 of  0 # PUSH  endof
  2 of  RAX RDX MOV  1 # RAX SAR  1 # RDX AND  RDX PUSH  endof
  4 of  RAX RDX MOV  2 # RAX SAR  3 # RDX AND  RDX PUSH  endof
  8 of  RAX RDX MOV  3 # RAX SAR  7 # RDX AND  RDX PUSH  endof
  16 of  RAX RDX MOV  4 # RAX SAR  15 # RDX AND  RDX PUSH  endof
  32 of  RAX RDX MOV  5 # RAX SAR  31 # RDX AND  RDX PUSH  endof
  64 of  RAX RDX MOV  6 # RAX SAR  63 # RDX AND  RDX PUSH  endof
  128 of  RAX RDX MOV  7 # RAX SAR  127 # RDX AND  RDX PUSH  endof
  256 of  RAX RDX MOV  8 # RAX SAR  255 # RDX AND  RDX PUSH  endof
  512 of  RAX RDX MOV  9 # RAX SAR  511 # RDX AND  RDX PUSH  endof
  1024 of  RAX RDX MOV  10 # RAX SAR  1023 # RDX AND  RDX PUSH  endof
  2048 of  RAX RDX MOV  11 # RAX SAR  2047 # RDX AND  RDX PUSH  endof
  4096 of  RAX RDX MOV  12 # RAX SAR  4095 # RDX AND  RDX PUSH  endof
  8192 of  RAX RDX MOV  13 # RAX SAR  8191 # RDX AND  RDX PUSH  endof
  16384 of  RAX RDX MOV  14 # RAX SAR  16383 # RDX AND  RDX PUSH  endof
  32768 of  RAX RDX MOV  15 # RAX SAR  32767 # RDX AND  RDX PUSH  endof
  65536 of  RAX RDX MOV  16 # RAX SAR  65535 # RDX AND  RDX PUSH  endof
  # RCX MOV  CQO  RCX IDIV  RDX PUSH  0 endcase ;
: [UQUOTREM], ( u -- )  case
  1 of  0 # PUSH  endof
  2 of  RAX RDX MOV  1 # RAX SHR  1 # RDX AND  RDX PUSH  endof
  4 of  RAX RDX MOV  2 # RAX SHR  3 # RDX AND  RDX PUSH  endof
  8 of  RAX RDX MOV  3 # RAX SHR  7 # RDX AND  RDX PUSH  endof
  16 of  RAX RDX MOV  4 # RAX SHR  15 # RDX AND  RDX PUSH  endof
  32 of  RAX RDX MOV  5 # RAX SHR  31 # RDX AND  RDX PUSH  endof
  64 of  RAX RDX MOV  6 # RAX SHR  63 # RDX AND  RDX PUSH  endof
  128 of  RAX RDX MOV  7 # RAX SHR  127 # RDX AND  RDX PUSH  endof
  256 of  RAX RDX MOV  8 # RAX SHR  255 # RDX AND  RDX PUSH  endof
  512 of  RAX RDX MOV  9 # RAX SHR  511 # RDX AND  RDX PUSH  endof
  1024 of  RAX RDX MOV  10 # RAX SHR  1023 # RDX AND  RDX PUSH  endof
  2048 of  RAX RDX MOV  11 # RAX SHR  2047 # RDX AND  RDX PUSH  endof
  4096 of  RAX RDX MOV  12 # RAX SHR  4095 # RDX AND  RDX PUSH  endof
  8192 of  RAX RDX MOV  13 # RAX SHR  8191 # RDX AND  RDX PUSH  endof
  16384 of  RAX RDX MOV  14 # RAX SHR  16383 # RDX AND  RDX PUSH  endof
  32768 of  RAX RDX MOV  15 # RAX SHR  32767 # RDX AND  RDX PUSH  endof
  65536 of  RAX RDX MOV  16 # RAX SHR  65535 # RDX AND  RDX PUSH  endof
  # RCX MOV  RDX RDX XOR  RCX DIV  RDX PUSH  0 endcase ;
: [MPYB], ( n -- )  case
  0 of  0 # BYTE PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  4 of  2 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  8 of  3 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  16 of  4 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  32 of  5 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  64 of  6 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  128 of  7 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  256 of  8 # BYTE PTR 0 [RAX] SAL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYB,  0 endcase ;
: [MPYC], ( u -- )  case
  0 of  0 # BYTE PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  4 of  2 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  8 of  3 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  16 of  4 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  32 of  5 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  64 of  6 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  128 of  7 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  256 of  8 # BYTE PTR 0 [RAX] SHL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYC,  0 endcase ;
: [MPYS], ( n -- )  case
  0 of  0 # WORD PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # WORD PTR 0 [RAX] SAL  DROP,  endof
  4 of  2 # WORD PTR 0 [RAX] SAL  DROP,  endof
  8 of  3 # WORD PTR 0 [RAX] SAL  DROP,  endof
  16 of  4 # WORD PTR 0 [RAX] SAL  DROP,  endof
  32 of  5 # WORD PTR 0 [RAX] SAL  DROP,  endof
  64 of  6 # WORD PTR 0 [RAX] SAL  DROP,  endof
  128 of  7 # WORD PTR 0 [RAX] SAL  DROP,  endof
  256 of  8 # WORD PTR 0 [RAX] SAL  DROP,  endof
  512 of  9 # WORD PTR 0 [RAX] SAL  DROP,  endof
  1024 of  10 # WORD PTR 0 [RAX] SAL  DROP,  endof
  2048 of  11 # WORD PTR 0 [RAX] SAL  DROP,  endof
  4096 of  12 # WORD PTR 0 [RAX] SAL  DROP,  endof
  8192 of  13 # WORD PTR 0 [RAX] SAL  DROP,  endof
  16384 of  14 # WORD PTR 0 [RAX] SAL  DROP,  endof
  32768 of  15 # WORD PTR 0 [RAX] SAL  DROP,  endof
  65536 of  16 # WORD PTR 0 [RAX] SAL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYS,  0 endcase ;
: [MPYW], ( u -- )  case
  0 of  0 # WORD PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # WORD PTR 0 [RAX] SHL  DROP,  endof
  4 of  2 # WORD PTR 0 [RAX] SHL  DROP,  endof
  8 of  3 # WORD PTR 0 [RAX] SHL  DROP,  endof
  16 of  4 # WORD PTR 0 [RAX] SHL  DROP,  endof
  32 of  5 # WORD PTR 0 [RAX] SHL  DROP,  endof
  64 of  6 # WORD PTR 0 [RAX] SHL  DROP,  endof
  128 of  7 # WORD PTR 0 [RAX] SHL  DROP,  endof
  256 of  8 # WORD PTR 0 [RAX] SHL  DROP,  endof
  512 of  9 # WORD PTR 0 [RAX] SHL  DROP,  endof
  1024 of  10 # WORD PTR 0 [RAX] SHL  DROP,  endof
  2048 of  11 # WORD PTR 0 [RAX] SHL  DROP,  endof
  4096 of  12 # WORD PTR 0 [RAX] SHL  DROP,  endof
  8192 of  13 # WORD PTR 0 [RAX] SHL  DROP,  endof
  16384 of  14 # WORD PTR 0 [RAX] SHL  DROP,  endof
  32768 of  15 # WORD PTR 0 [RAX] SHL  DROP,  endof
  65536 of  16 # WORD PTR 0 [RAX] SHL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYW,  0 endcase ;
: [MPYI], ( n -- )  case
  0 of  0 # DWORD PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  4 of  2 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  8 of  3 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  16 of  4 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  32 of  5 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  64 of  6 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  128 of  7 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  256 of  8 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  512 of  9 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  1024 of  10 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  2048 of  11 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  4096 of  12 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  8192 of  13 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  16384 of  14 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  32768 of  15 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  65536 of  16 # DWORD PTR 0 [RAX] SAL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYI,  0 endcase ;
: [MPYD], ( u -- )  case
  0 of  0 # DWORD PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  4 of  2 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  8 of  3 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  16 of  4 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  32 of  5 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  64 of  6 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  128 of  7 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  256 of  8 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  512 of  9 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  1024 of  10 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  2048 of  11 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  4096 of  12 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  8192 of  13 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  16384 of  14 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  32768 of  15 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  65536 of  16 # DWORD PTR 0 [RAX] SHL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYD,  0 endcase ;
: [MPYL], ( n -- )  case
  0 of  0 # QWORD PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  4 of  2 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  8 of  3 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  16 of  4 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  32 of  5 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  64 of  6 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  128 of  7 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  256 of  8 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  512 of  9 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  1024 of  10 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  2048 of  11 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  4096 of  12 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  8192 of  13 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  16384 of  14 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  32768 of  15 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  65536 of  16 # QWORD PTR 0 [RAX] SAL  DROP,  endof
  RAX PUSH  # RAX MOV  MPYL,  0 endcase ;
: [MPYQ], ( u -- )  case
  0 of  0 # QWORD PTR 0 [RAX] MOV  DROP,  endof
  1 of  DROP,  endof
  2 of  1 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  4 of  2 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  8 of  3 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  16 of  4 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  32 of  5 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  64 of  6 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  128 of  7 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  256 of  8 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  512 of  9 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  1024 of  10 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  2048 of  11 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  4096 of  12 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  8192 of  13 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  16384 of  14 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  32768 of  15 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  65536 of  16 # QWORD PTR 0 [RAX] SHL  DROP,  endof
  1 ADP+  RAX PUSH  1 ADP-  # RAX MOV  MPYQ,  0 endcase ;
: [DIVB], ( n -- )  case
  1 of  DROP,  endof
  2 of  1 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  4 of  2 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  8 of  3 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  16 of  4 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  32 of  5 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  64 of  6 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  128 of  7 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  256 of  8 # BYTE PTR 0 [RAX] SAR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVB,  0 endcase ;
: [DIVC], ( u -- )  case
  1 of  DROP,  endof
  2 of  1 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  4 of  2 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  8 of  3 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  16 of  4 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  32 of  5 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  64 of  6 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  128 of  7 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  256 of  8 # BYTE PTR 0 [RAX] SHR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVC,  0 endcase ;
: [DIVS], ( n -- )  case
  1 of  DROP,  endof
  2 of  1 # WORD PTR 0 [RAX] SAR  DROP,  endof
  4 of  2 # WORD PTR 0 [RAX] SAR  DROP,  endof
  8 of  3 # WORD PTR 0 [RAX] SAR  DROP,  endof
  16 of  4 # WORD PTR 0 [RAX] SAR  DROP,  endof
  32 of  5 # WORD PTR 0 [RAX] SAR  DROP,  endof
  64 of  6 # WORD PTR 0 [RAX] SAR  DROP,  endof
  128 of  7 # WORD PTR 0 [RAX] SAR  DROP,  endof
  256 of  8 # WORD PTR 0 [RAX] SAR  DROP,  endof
  512 of  9 # WORD PTR 0 [RAX] SAR  DROP,  endof
  1024 of  10 # WORD PTR 0 [RAX] SAR  DROP,  endof
  2048 of  11 # WORD PTR 0 [RAX] SAR  DROP,  endof
  4096 of  12 # WORD PTR 0 [RAX] SAR  DROP,  endof
  8192 of  13 # WORD PTR 0 [RAX] SAR  DROP,  endof
  16384 of  14 # WORD PTR 0 [RAX] SAR  DROP,  endof
  32768 of  15 # WORD PTR 0 [RAX] SAR  DROP,  endof
  65536 of  16 # WORD PTR 0 [RAX] SAR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVS,  0 endcase ;
: [DIVW], ( u -- )  case
  1 of  DROP,  endof
  2 of  1 # WORD PTR 0 [RAX] SHR  DROP,  endof
  4 of  2 # WORD PTR 0 [RAX] SHR  DROP,  endof
  8 of  3 # WORD PTR 0 [RAX] SHR  DROP,  endof
  16 of  4 # WORD PTR 0 [RAX] SHR  DROP,  endof
  32 of  5 # WORD PTR 0 [RAX] SHR  DROP,  endof
  64 of  6 # WORD PTR 0 [RAX] SHR  DROP,  endof
  128 of  7 # WORD PTR 0 [RAX] SHR  DROP,  endof
  256 of  8 # WORD PTR 0 [RAX] SHR  DROP,  endof
  512 of  9 # WORD PTR 0 [RAX] SHR  DROP,  endof
  1024 of  10 # WORD PTR 0 [RAX] SHR  DROP,  endof
  2048 of  11 # WORD PTR 0 [RAX] SHR  DROP,  endof
  4096 of  12 # WORD PTR 0 [RAX] SHR  DROP,  endof
  8192 of  13 # WORD PTR 0 [RAX] SHR  DROP,  endof
  16384 of  14 # WORD PTR 0 [RAX] SHR  DROP,  endof
  32768 of  15 # WORD PTR 0 [RAX] SHR  DROP,  endof
  65536 of  16 # WORD PTR 0 [RAX] SHR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVW,  0 endcase ;
: [DIVI], ( n -- )  case
  1 of  DROP,  endof
  2 of  1 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  4 of  2 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  8 of  3 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  16 of  4 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  32 of  5 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  64 of  6 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  128 of  7 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  256 of  8 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  512 of  9 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  1024 of  10 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  2048 of  11 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  4096 of  12 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  8192 of  13 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  16384 of  14 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  32768 of  15 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  65536 of  16 # DWORD PTR 0 [RAX] SAR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVI,  0 endcase ;
: [DIVD], ( u -- )  case
  1 of  DROP,  endof
  2 of  1 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  4 of  2 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  8 of  3 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  16 of  4 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  32 of  5 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  64 of  6 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  128 of  7 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  256 of  8 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  512 of  9 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  1024 of  10 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  2048 of  11 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  4096 of  12 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  8192 of  13 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  16384 of  14 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  32768 of  15 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  65536 of  16 # DWORD PTR 0 [RAX] SHR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVD,  0 endcase ;
: [DIVL], ( n -- )  case
  1 of  DROP,  endof
  2 of  1 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  4 of  2 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  8 of  3 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  16 of  4 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  32 of  5 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  64 of  6 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  128 of  7 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  256 of  8 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  512 of  9 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  1024 of  10 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  2048 of  11 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  4096 of  12 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  8192 of  13 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  16384 of  14 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  32768 of  15 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  65536 of  16 # QWORD PTR 0 [RAX] SAR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVL,  0 endcase ;
: [DIVQ], ( u -- )  case
  1 of  DROP,  endof
  2 of  1 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  4 of  2 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  8 of  3 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  16 of  4 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  32 of  5 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  64 of  6 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  128 of  7 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  256 of  8 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  512 of  9 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  1024 of  10 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  2048 of  11 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  4096 of  12 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  8192 of  13 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  16384 of  14 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  32768 of  15 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  65536 of  16 # QWORD PTR 0 [RAX] SHR  DROP,  endof
  RAX PUSH  # RAX MOV  DIVQ,  0 endcase ;
: [MODC], ( n -- )  case
  1 of  0 # BYTE PTR 0 [RAX] MOV  DROP,  endof
  2 of  1 # BYTE PTR 0 [RAX] AND  DROP,  endof
  4 of  3 # BYTE PTR 0 [RAX] AND  DROP,  endof
  8 of  7 # BYTE PTR 0 [RAX] AND  DROP,  endof
  16 of  15 # BYTE PTR 0 [RAX] AND  DROP,  endof
  32 of  31 # BYTE PTR 0 [RAX] AND  DROP,  endof
  64 of  63 # BYTE PTR 0 [RAX] AND  DROP,  endof
  128 of  127 # BYTE PTR 0 [RAX] AND  DROP,  endof
  256 of  255 # BYTE PTR 0 [RAX] AND  DROP,  endof
  RAX PUSH  # RAX MOV  MODC,  0 endcase ;
: [MODW], ( n -- )  case
  1 of  0 # WORD PTR 0 [RAX] MOV  DROP,  endof
  2 of  1 # WORD PTR 0 [RAX] AND  DROP,  endof
  4 of  3 # WORD PTR 0 [RAX] AND  DROP,  endof
  8 of  7 # WORD PTR 0 [RAX] AND  DROP,  endof
  16 of  15 # WORD PTR 0 [RAX] AND  DROP,  endof
  32 of  31 # WORD PTR 0 [RAX] AND  DROP,  endof
  64 of  63 # WORD PTR 0 [RAX] AND  DROP,  endof
  128 of  127 # WORD PTR 0 [RAX] AND  DROP,  endof
  256 of  255 # WORD PTR 0 [RAX] AND  DROP,  endof
  512 of  511 # WORD PTR 0 [RAX] AND  DROP,  endof
  1024 of  1023 # WORD PTR 0 [RAX] AND  DROP,  endof
  2048 of  2047 # WORD PTR 0 [RAX] AND  DROP,  endof
  4096 of  4095 # WORD PTR 0 [RAX] AND  DROP,  endof
  8192 of  8191 # WORD PTR 0 [RAX] AND  DROP,  endof
  16384 of  16383 # WORD PTR 0 [RAX] AND  DROP,  endof
  32768 of  32767 # WORD PTR 0 [RAX] AND  DROP,  endof
  65536 of  65535 # WORD PTR 0 [RAX] AND  DROP,  endof
  RAX PUSH  # RAX MOV  MODW,  0 endcase ;
: [MODD], ( n -- )  case
  1 of  0 # DWORD PTR 0 [RAX] MOV  DROP,  endof
  2 of  1 # DWORD PTR 0 [RAX] AND  DROP,  endof
  4 of  3 # DWORD PTR 0 [RAX] AND  DROP,  endof
  8 of  7 # DWORD PTR 0 [RAX] AND  DROP,  endof
  16 of  15 # DWORD PTR 0 [RAX] AND  DROP,  endof
  32 of  31 # DWORD PTR 0 [RAX] AND  DROP,  endof
  64 of  63 # DWORD PTR 0 [RAX] AND  DROP,  endof
  128 of  127 # DWORD PTR 0 [RAX] AND  DROP,  endof
  256 of  255 # DWORD PTR 0 [RAX] AND  DROP,  endof
  512 of  511 # DWORD PTR 0 [RAX] AND  DROP,  endof
  1024 of  1023 # DWORD PTR 0 [RAX] AND  DROP,  endof
  2048 of  2047 # DWORD PTR 0 [RAX] AND  DROP,  endof
  4096 of  4095 # DWORD PTR 0 [RAX] AND  DROP,  endof
  8192 of  8191 # DWORD PTR 0 [RAX] AND  DROP,  endof
  16384 of  16383 # DWORD PTR 0 [RAX] AND  DROP,  endof
  32768 of  32767 # DWORD PTR 0 [RAX] AND  DROP,  endof
  65536 of  65535 # DWORD PTR 0 [RAX] AND  DROP,  endof
  RAX PUSH  # RAX MOV  MODD,  0 endcase ;
: [MODQ], ( n -- )  case
  1 of  0 # QWORD PTR 0 [RAX] MOV  DROP,  endof
  2 of  1 # QWORD PTR 0 [RAX] AND  DROP,  endof
  4 of  3 # QWORD PTR 0 [RAX] AND  DROP,  endof
  8 of  7 # QWORD PTR 0 [RAX] AND  DROP,  endof
  16 of  15 # QWORD PTR 0 [RAX] AND  DROP,  endof
  32 of  31 # QWORD PTR 0 [RAX] AND  DROP,  endof
  64 of  63 # QWORD PTR 0 [RAX] AND  DROP,  endof
  128 of  127 # QWORD PTR 0 [RAX] AND  DROP,  endof
  256 of  255 # QWORD PTR 0 [RAX] AND  DROP,  endof
  512 of  511 # QWORD PTR 0 [RAX] AND  DROP,  endof
  1024 of  1023 # QWORD PTR 0 [RAX] AND  DROP,  endof
  2048 of  2047 # QWORD PTR 0 [RAX] AND  DROP,  endof
  4096 of  4095 # QWORD PTR 0 [RAX] AND  DROP,  endof
  8192 of  8191 # QWORD PTR 0 [RAX] AND  DROP,  endof
  16384 of  16383 # QWORD PTR 0 [RAX] AND  DROP,  endof
  32768 of  32767 # QWORD PTR 0 [RAX] AND  DROP,  endof
  65536 of  65535 # QWORD PTR 0 [RAX] AND  DROP,  endof
  RAX PUSH  # RAX MOV  MODQ,  0 endcase ;

: [UNUMBUILD],  SWAP, 1 ADP+ [UTIMES], 1 ADP- PLUS, ;
: [UNUMBUILDAT],  [MPYQ],  RAX 0 [RCX] ADD  RAX POP ;

previous
previous definitions
