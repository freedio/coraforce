( Copyright © 2020 by Coradec GmbH.  All rights reserved. )

=== Linux System Macro Forcembler Vocabulary ===

( For portability reasons, never put assembly code directly into words.  Instead, create a macro forcembler vocabulary and
  wrap the assembler code into a macro.  This way, only the macro forcembler vocabularies need to be ported.
)

( Register Usage:
  RSP:  Parameter Stack Pointer
  RBP:  Return Stack Pointer
  RAX:  Top of parameter stack [accumulator]
  RBX:  Scratch register
  RCX:  Scratch register
  RDX:  Scratch register
  RSI:  Scratch register
  RDI:  Scratch register
  R08:  MY/ME/THIS (Top of object stack)
  R09:  X-Stack Pointer
  R10:  Y-Stack Pointer
  R11:  Z-Stack Pointer
  R12:  Address of Return Stack Descriptor
  R13:  Address of X-Stack Descriptor
  R14:  Address of Y-Stack Descriptor
  R15:  Address of Z-Stack Descriptor
)

(
  Linux system calls
  ------------------
  Syscall#     RAX
  Arg 1        RDI
  Arg 2        RSI
  Arg 3        RDX
  Arg 4        R10
  Arg 5        R08
  Arg 6        R09
  Returns      RAX
  May change   RCX
  Invoke       SYSCALL

   More info about the individual system calls:
   - http://main.lv/notes/syscalls.md#toc-2
   - Linux man pages: man 2 xxxx (for BYE, and TERMINATE, xxxx is _exit)
)

( Glossary:
  fd            File Descriptor, obtained from SYS-OPEN | SYS-CREATE, subsequently used for all operations on the file object.
  |-errno       "Good" result is positive, error code is negative
  x⁰            Zero-terminated string x
  r|0|-errno    Depending on selected operation, return positive result r, 0 for "nothing", or negative error code.
)

vocabulary: SystemMacro  package linux/intel/64/system

code: RESULT0, ( 0|-errno -- t | errno f )            ( transform SYS-result into FORCE result )
  RAX NEG  CY IF  RAX PUSH  THEN  CMC  RAX RAX SBB ;
code: RESULT1, ( x|-errno -- x t | errno f )          ( transform SYS-result into FORCE result )
  63 # RAX BT  CY IF  RAX NEG  THEN  RAX PUSH  CMC  RAX RAX SBB ;

code: BYE, ( -- )  RDI RDI XOR  60 # CALLINUX ;       ( terminate the current process with exit code 0 [success] )
code: SYS-TERMINATE, ( u -- )  RAX RDI MOV  60 # CALLINUX ;    ( terminate the current process with exit code u )
code: SYS-READ, ( a u1 fd -- u2|-errno )              ( read u1 bytes from fd into buffer a, reporting actual #bytes read u2 )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  0 # CALLINUX  RDI POP  RSI POP ;
code: SYS-WRITE, ( a u1 fd -- u2|-errno )             ( write u1 bytes from buffer a to fd, reporting actual bytes written u2 )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  1 # CALLINUX  RDI POP  RSI POP ;
code: SYS-OPEN, ( fn⁰ fl md -- fd|-errno )            ( open file fd with name fn⁰ flags fl and mode md )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  2 # CALLINUX  RSI POP  RDI POP ;
code: SYS-CLOSE, ( fd -- 0|-errno )                   ( close file fd )
  RDI PUSH  RAX RDI MOV  3 # CALLINUX  RDI POP ;
code: SYS-STAT, ( a fn⁰ -- 0|-errno )                 ( report status of file with name fn⁰ in buffer a )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  4 # CALLINUX  RDI POP  RSI POP ;
code: SYS-FSTAT, ( a fd -- 0|-errno )                 ( report status of open file fd in buffer a )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  5 # CALLINUX  RDI POP  RSI POP ;
code: SYS-LSTAT, ( a fn⁰ -- 0|-errno )                ( report status of link with name fn⁰ in buffer a )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  6 # CALLINUX  RDI POP  RSI POP ;
code: SYS-POLL, ( @p[] #p t -- #|-errno )             ( poll for events @p[]#p with timeout t and report #events in # )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  7 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SEEK, ( u1 og fd -- u2|-errno )             ( position cursor of fd at u1 from origin og and report cursor pos u2 )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  8 # CALLINUX  RDI POP  RSI POP ;
code: SYS-MMAP, ( a # pr fl u fd -- a'|-errno )       ( map # bytes at u in fd at [around] a with flags fl and protection pr¹ )
  ( ¹ reports exact location a' of area. u must be a multiple of page size, but # needs not )
  RDI 4 CELLS [RSP] XCHG  RSI 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  R09 0 [RSP] XCHG  R08 PUSH
  RAX R08 MOV  9 # CALLINUX  R08 POP  R09 POP  R10 POP  RDX POP  RSI POP  RDI POP ;
code: SYS-MPROTECT ( a # pr -- 0|-errno )             ( protect # bytes from a with protection pr )
  RDI CELL [RSP] XCHG  0 [RSP] RSI XCHG  RAX RDX MOV  10 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MUNMAP, ( a # -- 0|-errno )                 ( unmap # bytes from a )
  RDI CELL [RSP] XCHG  RSI PUSH  RX RSI MOV  11 # CALLINUX  RSI POP  RDI POP ;
code: SYS-BRK, ( a -- a' )                            ( set program break to a, return new or current program break )
  RDI PUSH  RAX RDI MOV  12 # CALLINUX  RDI POP ;
code: SYS-SIGACTION, ( a1 a0 u # -- 0|-errno )        ( set action descr for signal u to a1 and report old one in a0¹ )
  ( ¹ doesn't set if a1 is 0; doesn't report if a0 is 0; # is the size of the SA_MASK field in structure a0|a1 )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RDI 0 [RSP] XCHG  R10 PUSH  RAX R10 MOV  13 # CALLINUX
  R10 POP  RDI POP  RDX POP  RSI POP ;
code: SYS-SIGPROCMASK, ( a1 a0 how -- 0|-errno )      ( set masked signal set for action u to a1 and report old one in a0¹ )
  ( ¹ doesn't set if a1 is 0; doesn't report if a0 is 0; how specified if the mask is set, added or removed )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  R10 PUSH  CELL # R10 MOV  14 # CALLINUX  R10 POP  RDI POP  RSI POP ;
code: SYS-IOCTL, ( @args cmd fd -- x|0|-errno )       ( perform IO command cmd with args @args on file fd, return value x or 0 )
  RDX 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDI PUSH  RAX RDI MOV  16 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-PREAD, ( a # u fd -- #'|-errno )            ( read # bytes from abs pos u of fd into buffer at a, report #bytes read )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  17 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-PWRITE ( a # u fd -- #'|-errno )            ( write # bytes from a to abs pos u of fd, report #bytes read #' )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  18 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-READV, ( @v #v fd -- #|-errno )             ( read data from fd into vector @v#v, report # total bytes read )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  19 # CALLINUX  RDI POP  RSI POP ;
code: SYS-WRITEV, ( @v #v fd -- #|-errno )            ( write vector @v#v to file fd, report # total bytes written )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  20 # CALLINUX  RDI POP  RSI POP ;
code: SYS-ACCESS, ( fn⁰ md -- 0|-errno )              ( check caller access permissions md on file fn⁰, return 0 if granted )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  21 # CALLINUX  RSI POP  RDI POP ;
code: SYS-PIPE, ( @fds -- 0|-errno )                  ( create pipe, return reader fd in @fds[0], writer fd in @fds[1] )
  RDI PUSH  RAX RDI MOV  22 # CALLINUX  RDI POP ;
code: SYS-SELECT, ( @in @out @ex @to fd# -- u|-errn ) ( monitor fds in @in+@out+@ex, highest fd+1 in fd# for ready within @to¹ )
  ( @to = timeout interval, @in = ready for read, @out = ready for write, @ex = with exception, u = total rdy fds in all sets )
  RSI 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  R08 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  23 # CALLINUX
  RDI POP  R09 POP  R10 POP  RDX POP  RSI POP ;
code: SYS-YIELD, ( -- )  SAVE,  24 # CALLINUX  RESTORE, ;    ( Causes current thread to yield in favor of other processes )
code: SYS-MREMAP, ( a0 a1 #0 #1 fl -- a1'|-errno )    ( expand or shrink memory a0#0 to [a1]#1, return final address a1' )
  RDI 3 CELLS [RSP] XCHG  R08 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  25 # CALLINUX
  R10 POP  RSI POP  R08 POP  RDI POP ;
code: SYS-MSYNC ( a # fl -- 0|-errno )                ( sync mmapped area a# with underlying file according to flags fl )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  26 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MINCORE, ( a # @v -- 0|-errno )             ( check if memory between a and a+#is resident in memory, report to @vec )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  27 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MADVISE, ( a # fl -- 0|-errno )             ( give advice fl for usage of memory a# )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  28 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SHMGET, ( key # fl -- id|-errno )           ( Identifier id of shared memory segment with key ...¹ )
  ( under conditions of flags fl, a new shared memory area of size # is created )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  29 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SHMAT, ( a1 id fl -- a1|-errno )         ( attach shm seg id to caller at a1 according to fl, return addr of att seg )
  RSI CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RAX RDX MOV  30 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SHMCTL, ( @buf id cmd -- x|-errno )         ( perform shm ctl op cmd to segment with id by ctl struct @buf, result x )
  RDX CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  31 # CALLINUX  RSI POP  RDI POP  RDX POP ;
code: SYS-DUPFD ( fd -- fd'|-errno )                  ( duplicate file descriptor fd, report duplicate fd' )
  RDI PUSH  RAX RDI MOV  32 # CALLINUX  RDI POP ;
code: SYS-DUP2, ( fd1 fd2 -- 0|-errno )               ( duplicate file descriptor fd1 into fd2 )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  33 # CALLINUX  RSI POP  RDI POP ;
code: SYS-PAUSE, ( -- )  SAVE,  34 # CALLINUX  RESTORE, ;  ( wait for a signal )
code: SYS-NANOSLEEP, ( @t1 @t2 -- 0|-errno )          ( suspend caller for @t1, report remaining time in @t2 if interrupted )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  35 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETITIMER, ( @tv tp -- 0|-errno )           ( Timer value of type tp → @tv )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  36 # CALLINUX  RDI POP  RSI POP ;
code: SYS-ALARM, ( u1 -- u2|-errno )                  ( set alarm to u1 secs / cancel alarm if u1=0, return previous alarm u2 )
  RDI PUSH  RAX RDI MOV  37 # CALLINUX  RDI POP ;
code: SYS-SETITIMER, ( @tv1 @tv2 tp -- 0|-errno )     ( Arms or disarms timer of type tp using @tv1, report previous in @tv2 )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  38 # CALLINUX  PDI POP  RSI POP ;
code: SYS-GETPID ( -- pid )                           ( Caller's process ID, cannot fail )
  SAVE,  39 # CALLINUX ;
code: SYS-SENDFILE ( infd outfd @u u1 -- u2|-errno )  ( write u1 bytes from infd to outfd [mmapped]¹, report #written in u2 )
  ( ¹ use and update file cursor @u unless 0 instead of infd file position )
  RSI 2 CELLS [RSP] XCHG  RDI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  40 # CALLINUX  R10 POP  RDI POP  RSI POP ;
code: SYS-SOCKET ( fam tp prot -- fd|-errno )         ( create socket fd of family fam and type tp using protocol prot )
  RDI CELL [RSP] XCHG  RSI 0 [RSP]  RX RDX MOV  41 # CALLINUX  RSI POP  RDI POP ;
code: SYS-CONNECT ( a # fd -- 0|-errno )              ( connect socket fd with memory block a# )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDX MOV  42 # CALLINUX  RDI POP  RSI POP ;
code: SYS-ACCEPT, ( a # fd1 -- fd2|-errno )           ( connect client socket fd2 cor conn req on server socket fd1¹ )
  ( ¹ fills in client address in structure a# )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  43 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SENDTO, ( a # @s #s fl fd -- u|-errno )     ( send a# to socket fd with socket addr @s#s according to flags fl¹ )
  ( ¹ @s#s used only for connection-less sockets, otherwise must be NIL and 0, returns #bytes written u )
  RSI 4 CELLS [RSP] XCHG  RDX 3 CELLS [RSP] XCHG  R08 2 CELLS [RSP] XCHG  R09 CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH
  RAX RDI MOV  44 # CALLINUX  RDI POP  R10 POP  R09 POP  R08 POP  RDX POP  RSI POP ;
code: SYS-RECVFROM, ( a # @s #s fl fd -- u|-errno )   ( read a#  from socket fd with socket addr @s#s according to flags fl¹ )
  ( ¹ @s#s used only for connection-less sockets, otherwise must be NIL and 0, returns #bytes read u )
  RSI 4 CELLS [RSP] XCHG  RDX 3 CELLS [RSP] XCHG  R08 2 CELLS [RSP] XCHG  R09 CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH
  RAX RDI MOV  45 # CALLINUX  RDI POP  R10 POP  R09 POP  R08 POP  RDX POP  RSI POP ;
code: SYS-SENDMSG, ( @msg fl fd -- u|-errno )         ( send message @msg to socket fd according to flags fl¹ )
  ( ¹ return #bytes sent u )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  46 # CALLINUX  RDI POP  RSI POP ;
code: SYS-RECVMSG, ( @msg fl fd -- u|-errno )         ( read message @msg from socket fd according to flags fl¹ )
  ( ¹ return #bytes read u )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  47 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SHUTDOWN, ( tp fd -- 0|-errno )             ( shutdown part of full-duplex connection on socket fd according to fd¹ )
  ( ¹ fd: 0→receiving, 1→sending, 2→both )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  48 # CALLINUX  RDI POP  RSI POP ;
code: SYS-BIND, ( a # fd -- 0|-errno )                ( bind socket fd to socket descriptor a# )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  49 # CALLINUX  RDI POP  RSI POP ;
code: SYS-LISTEN, ( fd u -- 0|-errno )                ( mark socket fd as passive, listening for incoming requests¹ )
  ( ¹ u = maximum backlog )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  50 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETSOCKNAME, ( a # fd -- 0|-errno )         ( return socket fd descriptor in a# )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  51 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETPEERNAME, ( a # fd -- 0|-errno )         ( return socket descriptor for peer of socket fd in a# )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  52 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SOCKETPAIR, ( dom tp prot @s -- 0|-errno )  ( create unnamed socket of type tp in domain dom using protocol prot¹ )
  ( ¹ prot is optional, socket fds are reported in @s[0] and @s[1] )
  RDI 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  53 # CALLINUX  R10 POP  RSI POP  RDI POP ;
code: SYS-SETSOCKOPT, ( a # nm lv fd -- x|0|-errno )  ( Set socket fd option named nm on level lv from a#¹ )
  ( ¹ return netfilter specific handler value x or 0 if none )
  R10 3 CELLS [RSP] XCHG  R08 2 CELLS [RSP] XCHG  RDX CELL [RSP} XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  54 # CALLINUX
  RDI POP  RSI POP  RDX POP  R08 POP  R10 POP ;
code:  SYS-GETSOCKOPT, ( a # nm lv fd -- x|0|-errno ) ( Set socket fd option named nm on level lv from a#¹ )
  ( ¹ return netfilter specific handler value x or 0 if none )
  R10 3 CELLS [RSP] XCHG  R08 2 CELLS [RSP] XCHG  RDX CELL [RSP} XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  55 # CALLINUX
  RDI POP  RSI POP  RDX POP  R08 POP  R10 POP ;
code: SYS-CLONE, ( a @pt @ct fl -- tid|-errno )       ( create process clone sharing parent context according to flags fl¹ )
  ( ¹ child stack is set at a, its thread id reported in @pt for parent, @ct for child unless NIL, reports child tid )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  56 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-FORK, ( -- pid|-errno )  SAVE,  57 # CALLINUX ;    ( fork process, report childs pid )
code: SYS-VFORK, ( -- pid|-errno )  SAVE,  58 # CALLINUX ;   ( fork process halting parent until child calls execve or exit )
code: SYS-EXECVE, ( fn⁰ @args @env -- -errno )        ( execute program fn⁰, passing cmdline args @args and environment @env¹ )
  ( ¹ does not return if OK, only returns with errors )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  59 # CALLINUX  RSI POP  RDI POP ;
code: SYS-KILL, ( pid sig -- 0|-errno )               ( send signal sig to process pid )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  62 # CALLINUX  RSI POP  RDI POP ;
code: SYS-UNAME, ( a -- 0|-errno )                    ( return system information in structure at a )
  RDI PUSH  RAX RDI MOV  63 # CALLINUX  RDI POP ;
code: SYS-SEMGET, ( key sems# fl -- id|-errno )       ( Semaphore set id associated with key according to flags fl¹ )
  ( ¹ creates new semaphore set of size sems# under conditions specified in fl )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  64 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SEMOP, ( @semops #semops id -- 0|-errno )   ( atomically perform #semops semaphore ops in @semops on semaphore id )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  65 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SEMCTL3, ( id #sem cmd -- r|0|-errno )      ( perform 3-arg semaphore op cmd on semaphore #sem of set id¹ )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  66 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SEMCTL4, ( x id #sem cmd -- r|0|-errno )    ( perform 4-arg semaphore op cmd with arg x on semaphore #sem of set id¹ )
  R10 2 CELLS [RSP] XCHG  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  66 # CALLINUX  RSI POP  RDI POP  R10 POP ;
code: SYS-SHMDT, ( a -- 0|-errno )                    ( detach share memory area a from caller )
  RDI PUSH  RAX RDI MOV  67 # CALLINUX  RDI POP ;
code: SYS-MSGGET, ( k fl -- id|-errno )               ( Msg queue identifier id for key k according to flags fl )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  68 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MSGSND, ( a # fl id -- 0|-errno )           ( send message a# to msg queue id according to flags fl )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  69 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-MSGRCV, ( a # tp fl id -- u|-errno )        ( read message of type tp from msg queue id according to flags fl¹ )
  ( ¹ reports number of bytes actually read u )
  RSI 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  R08 [RSP] XCHG  RDI PUSH  RAX RDI MOV  70 # CALLINUX
  RDI POP  R08 POP  R10 POP  RDX POP  RSI POP ;
code: SYS-MSGCTL, ( a cmd id -- r|0|-errno )          ( perform ctrl op cmd on msq queue id with parameters a¹ )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  71 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-FCNTL, ( arg cmd fd -- r|0|-errno )         ( perform ctrl op cmd on file descr fd with parameters a¹ )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  72 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-FLOCK, ( cmd fd -- 0|-errno )               ( apply or remove advisory lock on fd )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  73 # CALLINUX  RDI POP  RSI POP ;
code: SYS-FSYNC, ( fd -- 0|-errno )                   ( flush dirty in-core data+meta-data of fd to storage )
  RDI PUSH  RAX RDI MOV  74 # CALLINUX  RDI POP ;
code: SYS-FDATASYNC, ( fd -- 0|-errno )               ( flush dirty in-core data, but not meta-data, of fd to storage )
  RDI PUSH  RAX RDI MOV  75 # CALLINUX  RDI POP ;
code: SYS-TRUNCATE, ( # fn⁰ -- 0|-errno )             ( truncate file fn⁰ to size #, filling with 0s if file was shorter )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  76 # CALLINUX  RDI POP  RSI POP ;
code: SYS-FTRUNCATE, ( # fd -- 0|-errno )             ( truncate file fd to size #, filling with 0s if file was shorter )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  77 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETDENTS, ( a # fd -- u|-errno )            ( read multiple directroy entries from fd into a#, return #bytes read u )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  78 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETCWD, ( a # -- 0|-errno )                 ( Current working directory in a# )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  79 # CALLINUX  RSI POP  RDI POP ;
code: SYS-CHDIR, ( fn⁰ -- 0|-errno )                  ( change working directory to path fn⁰ )
  RDI PUSH  RAX RDI MOV  80 # CALLINUX  RDI POP ;
code: SYS-FCHDIR, ( fd -- 0|-errno )                  ( change working directory to path of fd )
  RDI PUSH  RAX RDI MOV  81 # CALLINUX  RDI POP ;
code: SYS-RENAME, ( fn1⁰ fn2⁰ -- 0|-errno )           ( rename fn1⁰ to fn2⁰, moving between directories if necessary )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  82 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MKDIR, ( fn⁰ fl -- 0|-errno )               ( create directory fn⁰ according to flags fl )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  83 # CALLINUX  RSI POP  RDI POP ;
code: SYS-RMDIR, ( fn⁰ -- 0|-errno )                  ( remove directory fn⁰ )
  RDI PUSH  RAX RDI MOV  84 # CALLINUX  RDI POP ;
code: SYS-CREAT, ( fn⁰ fl -- fd|-errno )              ( create file fn⁰ and access mode fl, return its file descriptor fd )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  85 # CALLINUX  RSI POP  RDI POP ;
code: SYS-LINK, ( fn1⁰ fn2⁰ -- 0|-errno )             ( create file fn2⁰ pointing to same inode as fn1⁰ )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  86 # CALLINUX  RSI POP  RDI POP ;
code: SYS-UNLINK, ( fn⁰ -- 0|-errno )                 ( remove file fn⁰ from filesys, and its inode if fn⁰ was the last ref )
  RDI PUSH  RAX RDI MOV  87 # CALLINUX  RDI POP ;
code: SYS-SYMLINK, ( fn1⁰ fn2⁰ -- 0|-errno )          ( create symbolic link fn⁰ referring to file fn1⁰ )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  88 # CALLINUX  RSI POP  RDI POP ;
code: SYS-READLINK, ( a # fn⁰ -- u|-errno )           ( read content of symbolic link fn⁰ into buffer a#, return #bytes read u )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  89 # CALLINUX  RDI POP  RSI POP ;
code: SYS-CHMOD, ( mode fn⁰ -- 0|-errno )             ( change access mode of file fn⁰ to mod )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  90 # CALLINUX  RDI POP  RSI POP ;
code: SYS-FCHMOD, ( mode fd -- 0|-errno )             ( change access mode of fd to mod )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  91 # CALLINUX  RDI POP  RSI POP ;
code: SYS-CHOWN, ( uid gid fn⁰ -- 0|-errno )          ( change ownership of file fn⁰ to user uid / group gid )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  92 # CALLINUX  RDI POP  RSI POP ;
code: SYS-FCHOWN, ( uid gid fd -- 0|-errno )          ( change ownership of fd to user uid / group gid )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  93 # CALLINUX  RDI POP  RSI POP ;
code: SYS-LCHOWN, ( uid gid fn⁰ -- 0|-errno )         ( change ownership of symbolic link fn⁰ to user uid / group gid )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  94 # CALLINUX  RDI POP  RSI POP ;
code: SYS-UMASK, ( msk -- msk' )                      ( set file creation mask to msk, returning previous umask msk' )
  RDI PUSH  RAX RDI MOV  95 # CALLINUX  RDI POP ;
code: SYS-GETTIMEOFDAY, ( @time @zone -- 0|-errno )   ( Time of day in @time and time zone in @zone¹ )
  ( ¹ both @time and @zone can be NIL if the corresponding info is not wanted )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  96 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETRLIMIT, ( @rl u -- 0|-errno )            ( report soft and hard resource limit of resource u in @rl )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  97 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETRUSAGE, ( a who -- 0|errno )             ( report resource usage of who [self, children, thread] in buffer a )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  98 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETSYSINFO, ( a -- 0|-errno )               ( return system info in buffer a )
  RDI PUSH  RAX RDI MOV  99 # CALLINUX  RDI POP ;
code: SYS-TIMES, ( a -- t|-errno )                    ( fill block a with CPU times info, returning arbitrary elapsed time t )
  RDI PUSH  RAX RDI MOV  100 # CALLINUX  RDI POP ;
code: SYS-PTRACE, ( addr data pid req -- r|0|-errno ) ( performs trace request req with args in addr/data on thread pid¹ )
  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  101 # CALLINUX
  RDI POP  RSI POP  R10 POP  RDX POP ;
code: SYS-GETUID, ( -- uid )  SAVE,  102 # CALLINUX ; ( Real user id of caller. Never fails. )
code: SYS-SYSLOG, ( a # req -- r|0|-errno )           ( send request req with args a# to control and query kernel log buffer¹ )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  103 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETGID, ( -- gid )  SAVE,  104 # CALLINUX ; ( Real group id of caller. Never fails. )
code: SYS-SETUID, ( uid -- 0|-errno )                 ( set real/effective user id of caller to uid )
  RDI PUSH  RAX RDI MOV  105 # CALLINUX  RDI POP ;
code: SYS-SETGID, ( gid -- 0|-errno )                 ( set real/effective group id of caller to uid )
  RDI PUSH  RAX RDI MOV  106 # CALLINUX  RDI POP ;
code: SYS-GETEUID, ( -- uid )  SAVE, 107 # CALLINUX ; ( Effective user id of caller. Never fails. )
code: SYS-GETEGID, ( -- gid )  SAVE, 108 # CALLINUX ; ( Effective group id of caller. Never fails. )
code: SYS-SETPGID, ( pgid pid -- 0|-errno )           ( set group id of process pid to pgid )
  RSI 0 [RSP] XCHG  RDI PUSh  RAX RDI MOV  109 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETPPID, ( -- ppid )  SAVE,  110 # CALLINUX ;    ( Parent process id. Never fails. )
code: SYS-GETPGRP, ( -- pgrp )  SAVE,  111 # CALLINUX ;    ( Process group id of caller.  Never fails. )
code: SYS-SETSID, ( -- sid )  SAVE,  112 # CALLINUX ; ( Session id of new session with caller as group leader )
code: SYS-SETREUID, ( ruid euid -- 0|-errno )         ( set real and effective user id of caller, either can be -1 to not set )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  113 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SETREGID, ( rgid egid -- 0|-errno )         ( set real and effective group id of caller, either can be -1 to not set )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  114 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETGROUPS, ( @gid[] #gids -- u|-errno )     ( report list of supplementary groups in @gid[] of size #gids¹ )
  ( ¹ fails if the list is bigger than than #gids, unless #gids is 0: use gid# = 0 to report size of list )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  115 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SETGROUPS, ( @gid[] #gids -- 0|-errno )     ( set supplementary groups to @gid[] with size gids# )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  116 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SETRESUID, ( ruid euid suid -- 0|-errno )   ( set real, effective and saved user id, any can be -1 to not set )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  117 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETRESUID, ( @ruid @euid @suid -- 0|-err )  ( get real, effective and saved user id in respective variables )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  118 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SETRESGID, ( rgid egid sgid -- 0|-errno )   ( set real, effective and saved group id, any can be -1 to not set )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  119 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETRESGID, ( @rgid @egid @sgid -- 0|-err )  ( get real, effective and saved group id in respective variables )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RX RDX MOV  120 # CALLINUX  RSI POP  RDI POP ;
code: SYS-GETPGID, ( pid|0 -- pg|-errno )             ( Program group id of process pid, or caller if pid is 0 )
  RDI PUSH  RAX RDI MOV  121 # CALLINUX  RDI POP ;
code: SYS-GETSID, ( pid|0 -- sid|-errno )             ( Session id of process pid, or caller if pid is 0 )
  RDI PUSH  RAX RDI MOV  124 # CALLINUX  RDI POP ;
code: SYS-CAPGET, ( @hdr @data -- 0|-errno )          ( Thread capabilities of caller → @hdr and @data )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  125 # CALLINUX  RSI POP  RSI POP ;
code: SYS-CAPSET, ( @hdr @data -- 0|-errno )          ( set thread capabilities from @hdr and @data )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  126 # CALLINUX  RSI POP  RSI POP ;
code: SYS-SIGPENDING, ( @sigs -- 0|-errno )           ( Set of pending signals → @sigs )
  RSI PUSH  8 # ESI MOV  RDI PUSH  RAX RDI MOV  127 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SIGTIMEDWAIT, ( @tm @si @ss #ss -- sig|-errno )    ( wait for signal from signal set @ss#ss , reporting signo sig¹ )
  ( ¹ waits according to time spec @tm and sets @si to signal spec, when it happens )
  RDX 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDI 0 [RSP] XCHG  R10 PUSH  RAX R10 MOV  128 # CALLINUX
  R10 POP  RDI POP  RSI POP  RDX POP ;
code: SYS-RT_SIGQUEUINFO, ( @si sg tgid -- 0|-errno ) ( queue signal sg with args @si to task group tgid )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  129 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-SIGSUSPEND, ( @ss #ss -- -errno )           ( suspend caller waiting for signal in @ss#ss. Always fails¹ )
  ( ¹ with EINTR or EFAULT )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  130 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SIGALTSTACK, ( @ss @oss -- 0|-errno )       ( define [@ss] / query [@oss] alternate signal stack¹ )
  ( ¹ @ss can be NIL to query only, @oss can be NIL to set only, otherwise reports previous altstack in @oss )
  RSI 0 [RSP] XCHG  RSI PUSH  RX RSI MOV  131 # CALLINUX  RSI POP  RDI POP ;
code: SYS-UTIME, ( fn⁰ @ut -- 0|-errno )              ( set last accessed/modified time of file fn⁰ to utime structure @ut )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  132 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MKNOD, ( fn⁰ md dev -- 0|-errno )           ( create fs node named fn⁰ with mode md [and device dev¹] )
  ( ¹ dev is ignored unless for [block or char] device, in whch case it represents device major and minor code )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  133 # CALLINUX  RSI POP  RDI POP ;
code: SYS-USELIB, ( fn⁰ -- 0|-errno )                 ( load shared library fn⁰ )
  RDI PUSH  RAX RDI MOV  134 # CALLINUX  RDI POP ;
code: SYS-PERSONALITY, ( p1 -- p2|-errno )            ( set/get execution domain of each process to p1, report previous in p2¹ )
  ( ¹ p1 = -1 to only query the personality )
  RDI PUSH  RAX RDI MOV  135 # CALLINUX  RDI POP ;
code: SYS-STATFS, ( fn⁰ a -- 0|-errno )               ( report statistics of mounted fs containing file fn⁰ in buffer a )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  137 # CALLINUX  RSI POP  RDI POP ;
code: SYS-FSTATFS, ( fd a -- 0|-errno )               ( rport statistics of mounted fs containing open file fd in buffer a )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  138 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SYSFS, ( x1 x2 o -- u|-errno )              ( report various fs info according to option o with args x1, x2 in u )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  139 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GETPRIORITY, ( tp id -- p|-errno )          ( Scheduling priority [1..40] of tp with number id [0: caller]¹ )
  ( ¹ tp is process, pgroup or user, id is accordingly a pid, pgid or uid )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  140 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SETPRIORITY, ( tp id p -- 0|-errno )        ( set scheduling priority of tp with number id [0: caller] to p [1..40]¹ )
  ( ¹ tp is process, pgroup or user, id is accordingly pid, pgid or uid )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  141 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SCHED_SETPARAM, ( a pid -- 0|-errno )       ( set scheduling parameters of process pid [0: caller] to a )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  142 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SCHED_GETPARAM, ( a pid -- 0|-errno )       ( Scheduling parameters of process pid [0: caller] → a )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  143 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SCHED_SETSCHEDULER, ( p a pid -- 0|-errno ) ( set scheduling policy of process pid [0: caller] to p with args a )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  144 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SCHED_GETSCHEDULER, ( pid -- pol|-errno )   ( Scheduling policy of process pid [0: caller] )
  RDI PUSH  RAX RDI MOV  145 # CALLINUX  RDI POP ;
code: SYS-SCHED_GET_PRIORITY_MAX, ( pol -- p|-errno ) ( Maximum scheduling priority p of scheduling policy pol )
  RDI PUSH  RAX RDI MOV  146 # CALLINUX  RDI POP ;
code: SYS-SCHED_GET_PRIORITY_MIN, ( pol -- p|-errno ) ( Minimum scheduling priority p of scheduling policy pol )
  RDI PUSH  RAX RDI MOV  147 # CALLINUX  RDI POP ;
code: SYS-SCHED_RR_GET_INTERVAL, ( @t pid -- 0|-errno )    ( Round-robin time quantum for process pid¹ → @t )
  ( ¹ pid should run under the round-robin scheduling policy )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  148 # CALLINUX  RDI POP  RSI POP ;
code: SYS-MLOCK, ( a # -- 0|-errno )                  ( lock area a# of caller's virtual memory from being swapped¹ )
  ( ¹ locking is page-wise: all pages containing the specified address range are locked )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  149 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MUNLOCK, ( a # -- 0|-errno )                ( unlock area a# of caller's virtual memory from being swapped¹ )
  ( ¹ locking is page-wise: all pages containing the specified address range are locked )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  150 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MLOCKALL, ( fl -- 0|-errno )                ( lock caller's entire virtual address space according to flags fl )
  RDI PUSH  RAX RDI MOV  151 # CALLINUX  RDI POP ;
code: SYS-MUNLOCKALL, ( -- 0|-errno )  SAVE,  152 # CALLINUX ;    ( unlock caller's entire virtual address space )
code: SYS-VHANGUP, ( -- 0|-errno )  SAVE,  153 # CALLINUX ;    ( virtually hangs up the current terminal )
code: SYS-MODIFY_LDT, ( a # cmd -- u|0|-errno )       ( set/get LDT from/into descriptor a# according to command cmd¹ )
  ( ¹ 0: read, 1: write, returns number of bytes read or 0 for write )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  154 # CALLINUX  RDI POP  RSI POP ;
code: SYS-PIVOT_ROOT, ( @or⁰ @nr⁰ -- 0|-errno )       ( set new system root to @nr⁰ after saving old one to @or⁰ ¹ )
  ( ¹ both paths must refer to directories )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  155 # CALLINUX  RDI POP  RSI POP ;
code: SYS-PRCTL, ( x3 x2 x1 x0 cmd -- r|0|-errno )    ( perform process control op cmd with args x0..x3 on caller¹ )
  ( ¹ arguments used as well as result [r or 0] depend on command )
  R08 3 CELLS [RSP] XCHG  R10 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  157 # CALLINUX
  RDI POP  RSI POP  RDX POP  R10 POP  R08 POP ;
code: SYS-ADJTIMEX, ( a -- cs|-errno )                ( adjust and report timex algorithm parameter from/to timex struct a¹ )
  ( ¹ returns clock state cs )
  RDI PUSH  RAX RDI MOV  159 # CALLINUX  RDI POP ;
code: SYS-SETRLIMIT, ( @rlim u -- 0|-errno )          ( set resource limits of resource u to @rlim )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  160 # CALLINUX  RDI POP  RSI POP ;
code: SYS-CHROOT, ( fn⁰ -- 0|-errno )                 ( set caller's root directory to path fn⁰ )
  RDI PUSH  RAX RDI MOV  161 # CALLINUX  RDI POP ;
code: SYS-SYNC, ( -- )  SAVE,  162 # CALLINUX  RESTORE, ;    ( flush all pending modifications and metadata to underlying fs¹ )
code: SYS-ACCT, ( fn⁰|0 -- 0|-errno )                 ( turn on [or off if fn⁰ is NIL] accounting, logging to fn⁰ )
  RDI PUSH  RAX RDI MOV  163 # CALLINUX  RDI POP ;
code: SYS-SETTIMEOFDAY, ( @time|0 -- 0|-errno )       ( set time of day unless 0 )
  RDI PUSH  RSI PUSH  RAX RDI MOV  RSI RSI XOR  164 # CALLINUX  RSI POP  RDI POP ;
code: SYS-MOUNT, ( dev⁰ dir⁰ fs⁰ fl a -- 0|-errno )   ( mount fs fs⁰ in device dev⁰ on directory dir⁰ according to flags fl¹ )
  ( ¹ a points at a fs-specific data structure )
  RDI 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  0 [RSP] R10 XCHG  R08 PUSH  RAX R08 MOV  165 # CALLINUX
  R08 POP  R10 POP  RDX POP  RSI POP  RDI POP ;
code: SYS-UMOUNT2, ( tgt⁰ fl -- 0|-errno )            ( unmount top fs mounted on target tgt⁰ according to flags fl )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  166 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SWAPON, ( sfn⁰ fl -- 0|-errno )             ( adds swap area sfn⁰, a special file or block device with flags fl )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  167 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SWAPOFF, ( sfn⁰ -- 0|-errno )               ( remove swap area sfn⁰ )
  RDI PUSH  RAX RDI MOV  168 # CALLINUX  RDI POP ;
code: SYS-REBOOT, ( cmd -- 0|-errno )                 ( reboot system or enable/disable boot keystroke, depending on cmd¹ )
  ( ¹ does not return in case of reboot )
  RDI PUSH  RSI PUSH  R10 PUSH  $fee1dead # RDI MOV  $28121969 # RSI MOV  R10 R10 XOR  RAX RDX MOV 169 # CALLINUX
  R10 POP  RSI POP  RDI POP ;
code: SYS-REBOOT2, ( msg⁰ cmd -- 0|errno )            ( reboot system with the specified command and message )
  ( ¹ does not return in case of reboot )
  0 [RSP] R10 XCHG  RDI PUSH  RSI PUSH  $fee1dead # RDI MOV  $28121969 # RSI MOV  RAX RDX MOV 169 # CALLINUX
  RSI POP  RDI POP  R10 POP ;
code: SYS-SETHOSTNAME, ( a # -- 0|-errno )            ( set host name to string a# )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  170 # CALLINUX  RSI POP  RDI POP ;
code: SYS-SETDOMAINNAME, ( a # -- 0|-errno )          ( set the NIS domain name to string a# )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  170 # CALLINUX  RSI POP  RDI POP ;
code: SYS-IOPL, ( lvl -- 0|-errno )                   ( change caller's I/O privilege level to lvl )
  RDI PUSH  RAX RDI MOV  171 # CALLINUX  RDI POP ;
code: SYS-IOPERM, ( off # ? -- 0|-errno )             ( change raw I/O permissions of # ports from off to ? [0: off, ¬0: on] )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  172 # CALLINUX  RSI POP  RDI POP ;
code: SYS-INIT_MODULE, ( a # par⁰ -- 0|-errno )       ( load Linux ELF module image a# and init it with parameter string par⁰ )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  175 # CALLINUX  RSI POP  RDI POP ;
code: SYS-DELETE_MODULE, ( mn⁰ fl -- 0|-errno )       ( remove Linux ELF module with name mn⁰ acceording to flags fl )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  176 # CALLINUX  RSI POP  RDI POP ;
code: SYS-QUERY_MODULE, ( mn⁰ a # @# cmd -- 0|-errno ) ( request info about loaded module mn⁰ in buffer a# using command cmd¹ )
  ( ¹ report numbers in cell at @#.  mn⁰ is NIL for the kernel proper )
  RDI 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  R08 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  178 # CALLINUX
  RSI POP  R08 POP  R10 POP  RDX POP  RDI POP ;
code: SYS-QUOTACTL, ( a dv⁰ id cmd -- 0|-errno )      ( manipulate disk quotas for mounted block device dv⁰ using command cmd¹ )
  ( ¹ command refers to entity [user, group, project] id; buffer a is used to pass in/out data for some commands )
  R10 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  179 # CALLINUX  RDI POP  RSI POP  R10 POP ;
code: SYS-GETTID, ( -- tid )  SAVE,  180 # CALLINUX ; ( Caller's Thread ID.  Never fails )
code: SYS-READAHEAD, ( off len fd -- 0|-errno )       ( init reading ahead len bytes from offset off in file fd¹ )
  ( ¹ off and len should fall on page boundaries, because this command only reads full pages )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  187 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SETXATTR, ( fn⁰ nm⁰ a # fl -- 0|-errno )    ( set xt'd attr nm⁰ for path fn⁰ to value a# according to flags fl )
  RDI 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  R08 PUSH  RAX R08 MOV  188 # CALLINUX
  R08 POP  R10 POP  RDX POP  RSI POP  RDI POP ;
code: SYS-LSETXATTR, ( fn⁰ nm⁰ a # fl -- 0|-errno )   ( set xt'd attr nm⁰ for link path fn⁰ to value a# according to flags fl )
  RDI 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  R08 PUSH  RAX R08 MOV  189 # CALLINUX
  R08 POP  R10 POP  RDX POP  RSI POP  RDI POP ;
code: SYS-FSETXATTR, ( fd nm⁰ a # fl -- 0|-errno )    ( set xt'd attr nm⁰ for file fd to value a# according to flags fl )
  RDI 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  R08 PUSH  RAX R08 MOV  190 # CALLINUX
  R08 POP  R10 POP  RDX POP  RSI POP  RDI POP ;
code: SYS-GETXATTR, ( fn⁰ nm⁰ a # -- u|-errno )       ( read xt'd attr nm⁰ for path fn⁰ into buffer a#, report result length u )
  RDI 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  191 # CALLINUX  R10 POP  RSI POP  RDI POP ;
code: SYS-LGETXATTR, ( fn⁰ nm⁰ a # -- u|-errno )      ( read xt'd attr nm⁰ for link path fn⁰ into buffer a#, result length → u )
  RDI 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  192 # CALLINUX  R10 POP  RSI POP  RDI POP ;
code: SYS-FGETXATTR, ( fd nm⁰ a # -- u|-errno )       ( read xt'd attr nm⁰ for file fd into buffer a#, report result length u )
  RDI 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  193 # CALLINUX  R10 POP  RSI POP  RDI POP ;
code: SYS-LISTXATTR, ( fn⁰ a # -- u|-errno )          ( list xt'd attrs of file fn⁰ as name⁰s in buffer a#, result length → u )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  194 # CALLINUX  RSI POP  RDI POP ;
code: SYS-LLISTXATTR, ( fn⁰ a # -- u|-errno )         ( list xt'd attrs of link fn⁰ as name⁰s in buffer a#, result length → u )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  195 # CALLINUX  RSI POP  RDI POP ;
code: SYS-FLISTXATTR, ( fd a # -- u|-errno )          ( list xt'd attrs of file fd as name⁰s in buffer a#, result length → u )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  196 # CALLINUX  RSI POP  RDI POP ;
code: SYS-REMOVEXATTR, ( fn⁰ nm⁰ -- 0|-errno )        ( remove xt'd attr nm⁰ from file fn⁰ )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  197 # CALLINUX  RSI POP  RDI POP ;
code: SYS-LREMOVEXATTR, ( fn⁰ nm⁰ -- 0|-errno )       ( remove xt'd attr nm⁰ from symbolic link fn⁰ )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  198 # CALLINUX  RSI POP  RDI POP ;
code: SYS-FREMOVEXATTR, ( fd nm⁰ -- 0|-errno )        ( remove xt'd attr nm⁰ from open file fd )
  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  199 # CALLINUX  RSI POP  RDI POP ;
code: SYS-TIME, ( -- u )  SAVE,  RDI PUSH  RDI RDI XOR  201 # CALLINUX  RDI POP ;   ( Current Time in secs since the Epoch )
code: SYS-FUTEX, ( @f1 v op @t|v2 @f2 v3 -- r|0|-errno )    ( perform futex blocking operation¹, returning reply r or 0 )
  ( ¹ operation op with arg v to wait for condition on on futex @f1, possibly with timeout @t or second value v2, another
      futex @f2 and an additional value v3 )
  RDI 4 CELLS [RSP] XCHG  RDX 3 CELLS [RSP] XCHG  RSI 2 CELL [RSP]  R10 CELL [RSP] XCHG  R08 0 [RSP] XCHG  R09 PUSH  RAX R09 MOV
  202 # CALLINUX  R09 POP  R08 POP  R10 POP  RSI POP  RDX POP  RDI POP ;
code: SYS-SCHED_SETAFFINITY, ( a # pid -- 0|-errno )  ( set CPU affinity of thread pid [0=caller] in CPU set buffer a# )
  RDX POP  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  203 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SCHED_GETAFFINITY, ( a # pid -- 0|-errno )  ( report CPU affinity of thread pid [0=caller] in CPU set buffer a# )
  RDX POP  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  204 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SET_THREAD_AREA, ( @udesc -- 0|-errno )     ( set thread-local storage according to descriptor @udesc )
  RDI PUSH  RAX RDI MOV  205 # CALLINUX  RDI POP ;
code: SYS-IO_SETUP, ( @aioc u -- 0|-errno )           ( create asynch I/O context for # operations, report in @aioc¹ )
  ( ¹ @aioc must be initialized to 0 before the call )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  206 # CALLINUX  RDI POP  RSI POP ;
code: SYS-IO_DESTROY, ( @aioc -- 0|-errno )           ( destroy asynch I/O context @aoic¹ )
  ( ¹ after cancelling all outstanding I/Os and blocking on completion of all uncancellable operations )
  RDI PUSH  RAX RDI MOV  207 # CALLINUX  RDI POP ;
code: SYS-IO_GETEVENTS, ( @e[], @t #1 #2 @aioc -- #3|-errno )    ( read at least #1 and up to #2 events from @aioc¹ )
  ( ¹ events stored in @e[] with space for at least #2 events; returns #3 = effective number of events read )
  R10 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  R08 CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  208 # CALLINUX
  RDI POP  R08 POP  RSI POP  R10 POP ;
code: SYS-IO_SUBMIT, ( @iocb[] # @aioc -- #'|-errno ) ( xfer # events from @ioc[] to @aioc, return #' of actually xferred )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  209 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-IO_CANCEL, ( @evt @iocb @aioc -- 0|-errno ) ( cancel event in @iocb in context @aioc returning cancelled evt in @evt )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  210 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-GET_THREAD_AREA, ( @udesc -- 0|-errno )     ( read GDT local storage paras of entry @udesc & fill out rest of descr )
  RDI PUSH  RAX RDI MOV  211 # CALLINUX  RDI POP ;
code: SYS-LOOKUP-DCOOKIE, ( a # cookie -- #'|-errno ) ( Full path of directory entry represented by cookie in buffer a# )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDi MOV  212 # CALLINUX  RDI POP  RSI POP ;
code: SYS-EPOLL_CREATE, ( # -- fd|-errno )            ( create epoll instance of aleast size #¹, returnings its fd )
  ( ¹ this parameter is ignored in newer kernels )
  RSI PUSH  RAX RDi MOV  213 # CALLINUX  RDI POP ;
code: SYS-GET_DENTS, ( @de[] # fd -- #'|-errno )      ( read # entries from directory fd into buffer @de[], report size #' )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  217 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SET_TID_ADDRESS, ( a -- tid|-errno )        ( set CLEAR_CHILD_TID for caller, returning this thread's tid )
  RDI PUSH  RAX RDI MOV  218 # CALLINUX  RDI POP ;
code: SYS-SEMTIMEDOP, ( @o #o @t semid -- 0|-errno )  ( perform semaphore ops @o#o on semaphore group semid with timeout @t )
  RSI 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  220 # CALLINUX  RDI POP  R10 POP  RSI POP ;
code: SYS-FADVISE64, ( off len adv fd -- 0|-errno )   ( announce intention to to read len bytes from offset off from file fd¹ )
  ( ¹ in the way declared in adv )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  221 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-TIMER_CREATE, ( @tmr @e ct -- 0|-errno )    ( create per-process timer @tmr of type ct sending event @e when expired )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  222 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-TIMER_SETTIME, ( @n @p @tmr fl -- 0|-errno ) ( arm timer @tmr with new interval @n according to flags fl¹ )
  ( ¹ reports previous interval in @p )
  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  223 # CALLINUX
  RSI POP  RDI POP  R10 POP  RDX POP ;
code: SYS-TIMER_GETTIME, ( @v @tmr -- 0|-errno )      ( Current value of timer @tmr → @v )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  224 # CALLINUX  RDI POP  RSI POP ;
code: SYS-TIMER_GETOVERRUN, ( @tmr -- u|-errno )      ( Overrun count u of timer @tmr )
  RDI PUSH  RAX RDI MOV  225 # CALLINUX  RDI POP ;
code: SYS-TIMER_DELETE, ( @tmr -- 0|-errno )          ( delete timer @tmr )
  RDI PUSH  RAX RDI MOV  226 # CALLINUX  RDI POP ;
code: SYS-CLOCK_SETTIME, ( @t @clk -- 0|-errno )      ( set time of clock @clk to @t )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  227 # CALLINUX  RDI POP  RSI POP ;
code: SYS-CLOCK_GETTIME, ( @t @clk -- 0|-errno )      ( Time of clock @clk → @t )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  228 # CALLINUX  RDI POP  RSI POP ;
code: SYS-CLOCK_GETRES, ( @t @clk -- 0|-errno )       ( Resolution of clock @clk → @t )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  229 # CALLINUX  RDI POP  RSI POP ;
code: SYS-CLOCK_NANOSLEEP, ( @tr @t fl @clk -- 0|-errno ) ( sleep for @t of type fl using clock @clk, report remainder in @tr¹ )
  ( ¹ fl could be 0 for relative time, or TIMER_ABSTIME for absolute time; remainder is reported only for relative, if @tr≠0 )
  R10 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV 230 # CALLINUX
  RDI POP  RSI POP  RDX POP  R10 POP ;
code: SYS-EXIT_GROUP, ( u -- )  RAX RDI MOV  231 # CALLINUX ;    ( terminate thread and all other threads of caller process¹ )
  ( ¹ does not return )
code: SYS-EPOLL_WAIT, ( @e[] #e tm|-1|0 epfd -- u|-errno )    ( wait for at most #e events on epoll epfd within timeout tm¹ )
  ( ¹ tm: -1 = forever, 0 = no wait, report events in @e of size #e and u = actual # events reported )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  232 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-EPOLL_CTL, ( @e fd op epfd -- 0|-errno )    ( perform ctlop op on target fd on behalf of epfd associated with @e¹ )
  ( ¹ @e is an event descriptor )
  R10 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  233 # CALLINUX
  RDI POP  RSI POP  RDX POP  R10 POP ;
code: SYS-TGKILL, ( pid tid sig -- 0|-errno )         ( send signal sig to thread tid in thread group[process] pid )
  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  234 # CALLINUX  RSI POP  RDI POP ;
code: SYS-UTIMES, ( @t[] fn⁰ -- 0|-errno )            ( set last-accessed @t[0] and last-modified @t[1] time of file fn⁰ ¹ )
  ( ¹ time precision is in ms )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  235 # CALLINUX  RDI POP  RSI POP ;
code: SYS-MBIND, ( @nm #nm fl md a # -- 0|-errno )    ( set NUMA policy of block a# to mode md with flags fl, applied to mask¹ )
  ( ¹ @nm points at a node mask of #nm bits )
  R10 4 CELLS [RSP] XCHG  R08 3 CELLS [RSP] XCHG  R09 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RSI PUSH
  RAX RSI MOV  237 # CALLINUX  RSI POP  RDI POP  RDX POP  R09 POP  R08 POP  R10 POP ;
code: SYS-SET_MEMPOLICY, ( @nm #nm md -- 0|-errno )   ( set caller's default NUMA policy to md for node mask @nm#nm¹ )
  ( ¹ @nm points at a node mask of #nm bits )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  238 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GET_MEMPOLICY, ( @nm #nm fl @m -- 0|-errno ) ( get callerd NUMA police regarding fl at a in @nm#nm and mode in @m )
  RSI 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  R08 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  239 # CALLINUX
  RDI POP  R08 POP  R10 POP  RDX POP  RSI POP ;
code: SYS-MQ_OPEN, ( mn⁰ @attr fl md -- mqd|-errno )  ( create/open POSIX MQ mn⁰ with attrs @attr, permissions md for mode fl¹ )
  ( ¹ returns message queue descriptor mqd )
  RDI 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  240 # CALLINUX  RSI POP  R10 POP  RDI POP ;
code: SYS-MQ_UNLINK, ( mn⁰ -- 0|-errno )              ( destroy message queue mn⁰ )
  RDI PUSH  RAX RDI MOV  241 # CALLINUX  RDI POP ;
code: SYS-MQ_TIMEDSEND, ( @tm @m #m u mqd -- 0|-errno ) ( send message @m#m with prio u to MQ mqd, waiting until abstime @tm¹ )
  ( ¹ if MQ is open in non-blocking mode, does not wait for free slot )
  R08 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  242 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP  R08 POP ;
code: SYS-MQ_TIMEDRECEIVE, ( @tm @m #m @u|0 mqd -- 0|-errno ) ( remove oldest message from mqd and return it in @m#m¹, prio→@u )
  ( ¹ waits up to absolute time @tm, unless MQ is non-blocking; reports message prio in @u, unless it is 0 )
  R08 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  243 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP  R08 POP ;
code: SYS-MQ_NOTIFY, ( @sev|0 mqd -- 0|-errno )       ( un~/register caller for asynch msg delivery with mqd with mode @sev¹ )
  ( ¹ unregister if @sev = 0, else @sev defines detail of event delivery mode )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  244 # CALLINUX  RDI POP  RSI POP ;
code: SYS-MQ_GETSETATTR, ( @n|0 @o|0 mqd -- 0|-errno ) ( get/set MQ attributes of mqd in @o/@n respectively¹ )
  ( ¹ if @n is 0, no attributes will be changed; if @o is 0, no attributes will be reported )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  245 # CALLINUX  RDI POP  RSI POP ;
code: SYS-KEXEC_LOAD, ( @s #s @e fl -- 0|-errno )     ( load reboot/crash kernel according to flags fl¹ )
  ( ¹ use #s segments starting at @s, set entry point to @e )
  RDX 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDI 0 [RSP] XCHG  R10 PUSH  RAX R10 MOV  246 # CALLINUX
  R10 POP  RDI POP  RSI POP  RDX POP ;
code: SYS-WAITID, ( @ru @sg opt pid tp -- 0|-errno )  ( wait for state change in child proc pid|0 of type tp of caller¹ )
  ( ¹type of state change in opt, returns signal in @sg and resource usage in @ru )
  R08 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  247 # CALLINUX
  RDI POP  RSI POP  R10 POP  RDX POP  R08 POP ;
code: SYS-ADD_KEY, ( @t @d @pl #pl kr -- sn|-errno )  ( create|update kernel key of type @t with payload @pl#pl to keyring kr¹ )
  ( ¹ @d is the key description; returns the key's serial number sn )
  RDI 3 CELLS [RSP] XCHG  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  R08 PUSH  RAX R08 MOV  248 # CALLINUX
  R08 POP  R10 POP  RDX POP  RSI POP  RDI POP ;
code: SYS-REQUEST_KEY, ( @t @d @co kr -- sn|-errno )  ( lookup key of type @t and attach to kernel keyring kr¹ )
  ( ¹ looks further according to callout @co if key was not found internally; returns found key's serial number sn )
  RDI 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  R10 PUSH  RAX R10 MOV  249 # CALLINUX  R10 POP  RSI POP  RDI POP ;
code: SYS-KEYCTL, ( a1 a2 a3 a4 op -- sn|-errno )     ( perform key control op using further arguments a1..a4¹ )
  ( ¹ returns key's serial number sn )
  R08 3 CELLS [RSP] XCHG  R10 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  250 # CALLINUX
  RDI POP  RSI POP  RDX POP  R10 POP  R08 POP ;
code: SYS-IOPRIO_SET, ( pr pid tp -- 0|-errno )       ( set I/O prio of pid of type tp to pr )
  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  251 # CALLINUX  RDI POP  RSI POP  RDX POP ;
code: SYS-IOPRIO_GET, ( pid tp -- pr|-errno )         ( I/O prio of pid of type tp → pr )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  252 # CALLINUX  RDI POP  RSI POP ;
code: SYS-INOTIFY_INIT, ( -- fd|-errno )  SAVE, 253 # CALLINUX ;    ( New inotify instance → fd )
code: SYS-INOTIFY_ADD_WATCH, ( fn⁰ m fd -- wd|-errno )  ( add file fn⁰ to inotify fd watching for events in mask m¹ )
  ( ¹ returns watch descriptor wd )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  254 # CALLINUX  RDI POP  RSI POP ;
code: SYS-INOTIFY_RM_WATCH, ( wd fd -- 0|-errno )     ( remove watch wd from inotify fd )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  255 # CALLINUX  RDI POP  RSI POP ;
code: SYS-MIGRATE_PAGES, ( @o @n #p pid -- u|-errno ) ( migrate #p pages of process pid in @o nodes to @n nodes¹ )
  ( ¹ reports number of pages migrated u )
  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  256 # CALLINUX
  RDI POP  RSI POP  R10 POP  RDX POP ;
code: SYS-OPENAT, ( fn⁰ fl md dfd -- fd|-errno )      ( like SYS-OPEN, but relative to directory descriptor dfd instead of CWD )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  257 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-MKDIRAT, ( fn⁰ md dfd -- 0|-errno )         ( like SYS-MKDIR, but relative to directory descr dfd instead of CWD )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  258 # CALLINUX  RDI POP  RSI POP ;
code: SYS-MKNODAT, ( fn⁰ md dev dfd -- 0|-errno )     ( like SYS-MKNOD, but relative to directory descr dfd instead of CWD )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  259 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-FCHOWNAT, ( fl uid gid fn⁰ dfd -- 0|-errno ) ( like SYS-FCHOWN, but relative to directory descr dfd instead of CWD )
  R08 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV
  260 # CALLINUX  RDI POP  RSI POP  R10 POP  RDX POP  R08 POP ;
code: SYS-FSTATAT, ( a fn⁰ fl dfd -- 0|-errno )       ( like SYS-FSTAT, but relative to directory descr dfd instead of CWD )
  RDX 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  262 # CALLINUX
  RDI POP  R10 POP  RSI POP  RDX POP ;
code: SYS-UNLINKAT, ( fn⁰ fl dfd -- 0|-errno )        ( like SYS-UNLINK, but relative to directory descr dfd instead of CWD )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  263 # CALLINUX  RDI POP  RSI POP ;
code: SYS-RENAMEAT, ( fn1⁰ fn2⁰ dfd1 dfd2 -- 0|-errno )  ( like SYS-RENAME, but relative to dfd1 and dfd2 instead of CWD )
  RSI 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RAX RDX MOV  264 # CALLINUX  RDI POP  R10 POP  RSI POP ;
code: SYS-LINKAT, ( fn1⁰ fn2⁰ dfd1 dfd2 -- 0|-errno ) ( like SYS-LINK, but relative to dfd1 and dfd2 instead of CWD )
  RSI 3 CELLS [RSP] XCHG  R10 2 CELLS [RSP] XCHG  R08 CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RAX RDX MOV  265 # CALLINUX
  RDI POP  R08 POP  R10 POP  RSI POP ;
code: SYS-SYMLINKAT, ( fn1⁰ fn2⁰ dfd2 -- 0|-errno )   ( like SYS-SYMLINK, but fn2⁰ relative to dfd2 instead of CWD )
  RDI CELL [RSP] XCHG  RDX POP  RSI PUSH  RAX RSI MOV  266 # CALLINUX  RSI POP  RDI POP ;
code: SYS-READLINKAT, ( a # fn⁰ dfd -- 0|-errno )     ( like SYS-READLINK, but relative to directory descr dfd instead of CWD )
  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  267 # CALLINUX
  RDI POP  RSI POP  R10 POP  RDX POP ;
code: SYS-FCHMODAT, ( fl md fn⁰ dfd -- 0|-errno )     ( like SYS-CHMOD, but relative to directory descr dfd instead of CWD )
  R10 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  268 # CALLINUX
  RSI POP  RDX POP  R10 POP ;
code: SYS-FACCESSAT, ( fl fn⁰ mode dfd -- 0|-errno )  ( like SYS-ACCESS, but relative to directory descr dfd instead of CWD )
  R10 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  269 # CALLINUX  RDI POP  RSI POP  R10 POP ;
code: SYS-PSELECT6, ( @sgm @in @out @ex @to fds -- u|-errno )  ( like SYS-SELECT, but allows to temporarily use sigmask @sgm¹ )
  ( ¹ @sgm is set and reset around the actual SELECT to prevent race conditions )
  R09 4 CELLS [RSP] XCHG  RSI 3 CELLS [RSP] XCHG  RDX 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  R08 0 [RSP] XCHG  RDI PUSH
  RAX RDI MOV  270 # CALLINUX  RDI POP  R08 POP  R10 POP  RDX POP  RSI POP  R09 POP ;
code: SYS-PPOLL, ( sst# @sgm @p[] #p @to -- #|-errno )  ( almost like SYSPOLL, but allows to temporarily use sigmask @sgm¹ )
  ( ¹ @sgm is set and reset around the actual SELECT to prevent race conditions )
  R08 3 CELLS [RSP] XCHG  R10 2 CELLS [RSP] XCHG  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RAX RDX MOV  271 # CALLINUX
  RSI POP  RDI POP  R10 POP  R08 POP ;
code: SYS-UNSHARE, ( fl -- 0|-errno )                 ( dissociate part of shared mem in exe context according to flags fl )
  RDI PUSH  RAX RDI MOV  272 # CALLINUX  RDI POP ;
code: SYS-SET_ROBUST_LIST, ( l #l -- 0|-errno )       ( set head l and length #l of caller's robust futexes )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  273 # CALLINUX  RDI POP  RSI POP ;
code: SYS-GET_ROBUST_LIST, ( @l @#l pid -- 0|-errno ) ( Head → @l and length → @#l of pid's robust futexes )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  274 # CALLINUX  RDI POP  RSI POP ;
code: SYS-SPLICE, ( # @in fdi @out fdo fl -- #'|-errno ) ( move # bytes from in of fdi to out of fdo according to flags fl¹ )
  ( ¹ returns actual #bytes transferred #' )
  R08 4 CELLS [RSP] XCHG  RSI 3 CELLS [RSP] XCHG  RDI 2 CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RDX POP  R09 PUSH  RAX R09 MOV
  275 # CALLINUX  R09 POP  R10 POP  RDI POP  RSI POP  R08 POP ;
code: SYS-TEE, ( # fdi fdo fl -- #'|-errno )          ( dup/branch # bytes from fdi to fdo, return #' actually transferred )
  RDX 2 CELLS [RSP] XCHG  RDI CELL [RSP] XCHG  RSI 0 [RSP] XCHG  R10 PUSH  RAX R10 MOV  276 # CALLINUX
  R10 POP t RSI POP  RDI POP  RDX POP ;
code: SYS-SYNC_FILE_RANGE, ( o # fl fd -- 0|-errno )  ( sync # bytes in file fd with underlying storage controlled by fl )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  277 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-VMSPLICE, ( @p #p fl fd -- #'|-errno )      ( map #p virtual mem pages described by @p to pipe fd according to fl¹ )
  ( ¹ retruns number of pages #' actually written )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  278 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-MOVE_PAGES, ( @p[] n[] st[] #ps fl pid -- 0|-errno )  ( move #p pages, addresses in @p[] of pid to nodes n[]¹ )
  ( ¹ controlled by flags fl; reports statuses in st[] )
  RDX 4 CELLS [RSP] XCHG  R10 3 CELLS [RSP] XCHG  R08 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  R09 0 [RSP] XCHG  RDI PUSH
  RAX RDI MOV  279 # CALLINUX  RDI POP  R09 POP  RSI POP  R08 POP  R10 POP  RDX POP ;
code: SYS-UTIMENSAT, ( fn⁰ t[2] fl dfd -- 0|-errno )  ( set last-acc and last-mod times of file fn⁰ to t[0]/t[1]¹ )
  ( ¹ controlled by flags fl; dfd is the base directory for relative filenames; t[n] are in nanoseconds )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  280 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-EPOLL_PWAIT, ( @s #s @to @e[] #e epfd -- u|-errno )
  ( wait for at most #e events of type spec'd in sigmask @s#s on epoll file epfd within timeout @to, to be reported in array
    @e[#e]; returns #e number of events delivered )
  R08 4 CELLS [RSP] XCHG  R09 3 CELLS [RSP] XCHG  R10 2 CELLS [RSP] XCHG  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV
  281 @ CALLINUX  RDI POP  RSI POP  R10 POP  R09 POP  R08 POP ;
code: SYS-SIGNALFD, ( @s #s sfd|-1 -- sfd'|-errno )   ( create or update signal fd sfd for signal mask @s#s¹ )
  ( ¹ if sfd=-1, a new signal fd sfd' is created, otherwise the signal mask is updated on sfd, and sfd'=sfd )
  RSI CELL [RSP] XCHG  RDX POP  RDI PUSH  RAX RDI MOV  282 # CALLINUX  RDI POP  RSI POP ;
code: SYS-TIMERFD_CREATE, ( clk fl -- tfd|-errno )    ( create timer fd tfd based on clock clk according to flags fl )
  RDI 0 [RSP] XCHG  RDI PUSH  RAX RSI MOV  283 # CALLINUX  RSI POP  RDI POP ;
code: SYS-EVENTFD, ( cnt -- efd|-errno )              ( create event fd efd with initial count cnt )
  RDI PUSH  RAX RDI MOV  284 # CALLINUX  RDI POP ;
code: SYS-FALLOCATE, ( off len md fd -- 0|-errno )    ( manipulate fd range at off with length len in fd according to mode md )
  RDX 2CELLS [RSP] XCHG  R10 CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  285 # CALLINUX
  RDI POP  RSI POP  R10 POP  RDX POP ;
code: SYS-TIMERFD_SETTIME, ( @n @o|0 fl tfd -- 0|-errno )  ( dis~/arms timer fd tfd from @n according to flags fl¹ )
  ( ¹ returns previous timer value in @o, unless it's 0 )
  R10 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  286 # CALLINUX
  RSI POP  RDI POP  R10 POP ;
code: SYS-TIMERFD_GETTIME, ( @cur tfd -- 0|-errno )   ( report current timer value of timer fd tfd in @cur )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  287 # CALLINUX  RDI POP  RSI POP ;
code: SYS-ACCEPT4, ( a # fl sfd -- cfd|-errno )       ( create client socket fd' for connreq on server socket sfd¹ )
  ( ¹ fills in client address in structure a#, sets socketflags fl and returns client socket cfd )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  288 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-SIGNALFD4, ( @s #s fl fd|-1 -- fd'|-errno ) ( create/update signal fd with specified flags for signals @s#s¹ )
  ( ¹ creates fd' if fd=-1, else updates fd and returns fd'=fd )
  RSI 2 CELLS [RSP] XCHG  RDX CELL [RSP] XCHG  R10 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  289 # CALLINUX
  RDI POP  R10 POP  RDX POP  RSI POP ;
code: SYS-EVENTFD2, ( fl cnt -- efd|-errno )          ( create event fd efd with flags fl and initial count cnt )
  RSI 0 [RSP] XCHG  RDI PUSH  RAX RDI MOV  290 # CALLINUX  RDI POP  RSI POP ;
code: SYS-EPOLL_CREATE1, ( fl -- fd|-errno )          ( create epoll instance fd with flags fl )
  RDI PUSH  RAX RDI MOV  291 # CALLINUX  RDI POP ;
code: SYS-DUP3, ( fl fd1 fd2 -- fd2|-errno )          ( same as SYS-DUP2, with possibility to set flags fl, e.g. O_CLOEXEC )
  RDX CELL [RSP] XCHG  RDI 0 [RSP] XCHG  RSI PUSH  RAX RSI MOV  292 # CALLINUX  RSI POP  RDI POP  RDX POP ;
code: SYS-PIPE2, ( @fd[] fl -- 0|-errno )             ( create pipe @fd[] fitted with flags fl¹ )
  ( ¹ reports reading end fd in @fd[0], writing end fd in @fd[1] )
  RSI 0[RSP] XCHG  RDI PUSH  RAX RDI MOV  293 # CALLINUX  RDI POP  RSI POP ;
code: SYS-INOTIFY_INIT1, ( fl -- ifd|-errno )         ( init new inotify instance ifd fitted with flags fl )
  RDI PUSH  RAX RDI MOV  294 # CALLINUX  RDI POP ;

vocabulary;
