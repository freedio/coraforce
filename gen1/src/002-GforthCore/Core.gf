\ FORCE Core for GForth Linux-4.19 amd64

\ Goals:
\ - Compile FORCE modules
\ - Generate binaries (vocabularies and executables)
\ - Cross-compilation



=== Preliminary stuff ===

------
It is not safe to use methods starting with an underscore ‹_› outside of an object (→ private method)
------

4096 constant PAGESIZE
$00090000 constant version

defer closeAll
: terminate cr ." ⇒ back to FORTH..." closeAll quit ;

--- Exception Handling ---

: indirect-threading-not-supported ( -- )  cr ." Indirect threading not yet supported!"  terminate ;
: token-threading-not-supported ( -- )  cr ." Token-threading not yet supported!"  terminate ;
: word-not-found ( a # -- )  cr ." Word not found: " qtype '!' emit  terminate ;
: word-not-found$ ( a$ -- )  count  word-not-found ;
: unknown-vocabulary-model ( u -- )  cr ." Unknown vocabulary model: " . '!' emit  terminate ;
: unknown-code-model ( u -- )  cr ." Unknown code model: " . '!' emit  terminate ;
: vocabulary-not-found ( $ -- )  cr ." Vocabulary «" type$  ." » not found!" terminate ;
: not-implemented ( -- )  cr ." Method not implemented!" terminate ;
: unbalanced-definition ( -- )  cr ." Unbalanced definition!" terminate ;
: invalid-secondary-held ( u -- )  cr ." Invalid secondary held: type=" . '!' emit  terminate ;
: condition-unknown ( $ -- )  cr ." Condition «" type$ ." » unknown!"  terminate ;
: has-multiple-results ( # $ -- )  cr qtype$ ."  has " . ." results — narrow the search!"  terminate ;
: module-not-found ( $ -- )  cr ." Module " qtype$ ."  not found!"  terminate ;
: vocabulary-has-no-name ( -- )  cr ." Vocabulary has no name!"  abort ;
: parameter-not-found ( $ -- )  cr ." Vocabulary parameter «" type$ ." » not found!"  terminate ;
: invalid-vocabulary-type ( act exp -- )  cr ." Invalid vocabulary type: expected " . ." but got " .  terminate ;
: module-not-found-in-package-tree ( $ -- )  cr ." Module " qtype$ ."  not found in package tree!" terminate ;




=== Segment Stack ===

create SEGSTACK 1024 allot
create SEGSP  SEGSTACK ,
: >SEGS  SEGSP @ !  8 SEGSP +! ;
: SEGS>  8 SEGSP -!  SEGSP @ @ ;
: SEGS@  SEGSP @ 8- @ ;
: SEGSDEPTH  SEGSP @ SEGSTACK - cell / ;



=== Compiler Heap Management ===

------
The compiler juggles a lot of heaps.  Every heap is described by 3 parameters:
  • ADDR: Start address of the heap
  • SIZE: Capacity of the heap in bytes.
  • USED: Amount of bytes already used.
These properties are captured in an object called HeapDescriptor.

‹@hd› stands for "address of heap descriptor"

Heaps should grow in pages (PAGESIZE bytes) and usually don't shrink (or then in pages, too).

A heap is active if it has been allocated, in other words if both ADDR and SIZE are not 0.
------

--- Heap Descriptor ---

0000  dup constant ADDR
cell+ dup constant SIZE
cell+ dup constant USED
cell+     constant Heap#

--- Heap Primitives ---

: haddr ( @hd -- @addr )  ADDR + ;  inline            ( Address of ADDR field )
: hsize ( @hd -- @size )  SIZE + ;  inline            ( Address of SIZE field )
: hused ( @hd -- @used )  USED + ;  inline            ( Address of USED field )
: haddr@ ( @hd -- a )  haddr @ ;  inline              ( Start address of the heap )
: hsize@ ( @hd -- u )  hsize @ ;  inline              ( Size of the heap )
: hused@ ( @hd -- u )  hused @ ;  inline              ( Usage of the heap )
: haddr! ( a @hd -- )  haddr ! ;  inline              ( set start address of heap at a )
: hsize! ( u @hd -- )  hsize ! ;  inline              ( set heap size to u )
: hused! ( u @hd -- )  hused ! ;  inline              ( set heap usage to u )
: hsize+! ( u @hd -- )  hsize +! ;  inline            ( Increase heap size by u )
: hused+! ( u @hd -- )  hused +! ;  inline            ( Increase heap usage by u )
: hused−! ( u @hd -- )  dup hused@ rot min swap hused −! ;    ( Decrease heap usage by u )
: hfree@ ( @hd -- u )  dup hsize@ swap hused@ - ;  inline    ( Remaining space on the heap )
: heap ( @hd -- addr used )  dup haddr@ swap hused@ ;  inline  ( Address and usage of heap )
: -heap ( @hd -- addr+used used )  dup haddr@ swap hused@ tuck + swap ;  ( End address and usage of heap )
: >hend ( @hd -- a )  heap + ;  inline                ( Address of first byte after heap )
: hempty? ( @hd -- ? )  hused@ 0= ;                   ( check if heap @hd is empty )
: hset ( u @hd -- a )  over PAGESIZE ->| tuck allocate throw    ( allocate the heap for usage u and return heap address )
  dup >r over haddr!  tuck hsize!  hused! r> ;

--- Heap Operations ---

: newHeap ( >name -- )  create 0 , 0 , 0 , ;          ( create named heap )
: _hallocate ( @hd -- )                               ( allocate the initial heap )
  PAGESIZE dup allocate throw rot tuck haddr!  tuck hsize!  0 swap hused! ;
defer printVoc
: #hgrow ( @hd u -- @hd )                             ( grow segment by at least u )
  over hsize@ + PAGESIZE ->| over haddr@ over resize throw 2 pick haddr! over hsize! ;
: !hfree ( @hd u -- @hd )  over hfree@ over u< if  #hgrow dup  then drop ;  ( make sure at least u bytes are available on heap @hd )
: !hactive ( @hd -- @hd )  dup haddr@ unless  dup _hallocate  then ;    ( make sure the heap is active )
: hallot ( # @hd -- a # )  2dup >hend 2swap  !hactive  over !hfree  hused+!  swap ;    ( allot # bytes on heap @hd → @allotted )
: 0hallot ( # @hd -- a # )  hallot  2dup 0 cfill ;
: h#, ( x # @hd -- )  !hactive  cell !hfree  rot over >hend ! hused+! ;    ( append # bytes of x to heap @hd )
: h, ( x @hd -- )  cell swap h#, ;                    ( append cell x to heap @hd )
: hd, ( d @hd -- )  4 swap h#, ;                      ( append unsigned double word w to heap @hd )
: hw, ( w @hd -- )  2 swap h#, ;                      ( append unsigned word w to heap @hd )
: hc, ( c @hd -- )  1 swap h#, ;                      ( append unsigned byte c to heap @hd )
: hf, ( @hd -- F: r -- )  !hactive  10 !hfree  dup >hend f!  10 swap hused+! ;    ( append 10byte float r to heap @hd )
: h$, ( $ @hd -- )  !hactive  over c@ 1+ tuck !hfree  dup >hend -rot  hused+!  over c@ 1+ cmove ;    ( append $ to heap @hd )
: ha#, ( a # @hd -- )  !hactive  over !hfree  dup >hend -rot  2dup hused+! drop cmove ;    ( append buffer a# to heap @hd )

--- Table Operations ---

------
A table is a list of heaps (called segments), as typically used in a vocabulary.
------

: createTable ( # -- a )  Heap# * dup allocate throw  dup rot 0 cfill ;    ( create table of # heaps and return its address )
: >segment ( a # -- a' )  Heap# * + ;                 ( Select the #th segment of table a )



=== Vocabulary Table ===

------
‹VTE› stands for «vocabulary table entry».
------

newHeap Vocabularies

--- Vocabulary Table Operations ---

defer printVocabularyName
: addVTE ( @voc -- )  Vocabularies h, ;               ( append vocabulary @voc to the vocabulary table )
: VTE[] ( u -- @vte )                                 ( Address @vte of uth vocabulary table entry )
  Vocabularies !hactive over cells  over hused@ u> if  cr ." VTE index out of range: " swap . ." ≥ " hused@ cell/ . abort  then
  haddr@ swap cells + ;
: vocabularies. ( -- )  cr ." List of vocabularies:"  ( Lists the vocabulary table )
  Vocabularies heap cell/ 0 ?do  dup @ cr ." • " printVocabularyName  cell+  loop  drop ;



=== Vocabulary ===

------
Vocabularies come in two flavours, choice up to the developer:
  • Structured: Words are defined in a dictionary, each word has pointers to its name [TEXT], code [CODE], constants [TEXT]
    and variables [DATA].  Using so may pointers inflates the model (particularly on 64-bit machines where every pointer is
    8 bytes), but makes vocabulary searches easier, possibly faster and allows a transparent approach to deferring definitions.
  • Compact: Words are compressed into the code segment, the only remaining pointer being the PFA pointing into either the
    TEXT segment (constants) or the DATA segment (variables).  Compact vocabularies are considerably smaller but require
    more effort (by the Core, not the developer) to get searching and particularly deferring definitions right and effective.

The term ‹variables› is used here in the general sense of «mutable data», as opposed to ‹constants›.

A vocabulary is the following list of heaps:
  • DICT  the dictionary contains the word list (structured).
  • CODE  the code segment contains the executable code (structured) or everything except data (compact).
  • DATA  the R/W data segment contains variables (mutable data).
  • TEXT  the R/O text segment contains word names, constants, PFAs (structured) or just constants (compact).
  • PARA  the parameter table contains module parameters and statistics, such as name, source, package, #words etc.
  • RELO  the relocation table contains address fixups for code loading.
  • SYMS  the symbol table contains linker symbols.
  • DEPS  the dependency table contains references to other vocabularies needed to execute this one.
  • DBUG  the debug segment contains debug information.

Stack effect comment:
  • seg# denotes a segment number
  • @sd denotes the address of a segment descriptor (like @hd for heap)
  • @seg denotes the start address of a segment
------

--- Structural Definitions ---

( Segment Numbers [seg#] )
 0 dup constant §DICT
1+ dup constant §CODE
1+ dup constant §DATA
1+ dup constant §TEXT
1+ dup constant §PARA
1+ dup constant §RELS
1+ dup constant §SYMS
1+ dup constant §DEPS
1+ dup constant §DBUG
1+ constant segments
    15 constant §VOCA

( Segment Names [segment$] )
create DICT$ ," dictionary"
create CODE$ ," code segment"
create DATA$ ," data segment"
create TEXT$ ," text segment"
create PARA$ ," parameter table"
create RELS$ ," relocation table"
create SYMS$ ," symbol table"
create DEPS$ ," dependency table"
create DBUG$ ," debug segment"
create SEGNAMES DICT$ , CODE$ , DATA$ , TEXT$ , PARA$ , RELS$ , SYMS$ , DEPS$ , DBUG$ ,

--- Static state ---

variable lastVoc                                      ( Last created vocabulary )
variable targetVoc                                    ( Current target vocabulary )
variable targetSegment                                ( Current target segment )
create currentPackage  256 allot                      ( Name of last selected package )
  currentPackage 0!

--- Vocabulary Model ---

variable VOCAMODEL
0 constant COMPACT-VOC
1 constant STRUCTURED-VOC

--- Vocabulary Primitives ---

: addr@ ( @voc seg# -- a )  >segment !hactive haddr@ ;  ( Start address of segment seg# in vocabulary @voc )
: vocseg ( @voc seg# -- a u )  >segment !hactive heap ; ( Start address and SIZE of segment seg# in vocabulary @voc )
: vocuse ( @voc seg# -- # )  >segment !hactive hused@ ; ( Usage # of segment seg# in vocabulary @voc )
: >offs ( a @voc seg# -- u )  >segment >hend - ;      ( transform address a to an offset in segment seg# of vocabulary @voc )
: tvoc@ ( -- @voc )  targetVoc @                      ( Current target vocabulary )
  ?dup unless  cr ." No target vocabulary!" terminate  then ;
: tvoc! ( @voc -- )  targetVoc ! ;                    ( make @voct the target vocabulary )
: →target↑ ( @voc -- )  targetVoc @ >x tvoc! ;        ( push current target and make @voc the target)
: target↓  ( -- )  x> tvoc! ;                         ( pop saved target )
: >seg ( seg# -- @sd )  tvoc@ swap >segment  !hactive ;    ( Address of segment descripter seg# )
: segaddr@ ( seg# -- a )  >seg haddr@ ;               ( Start address of segment seg# in target vocabulary )
: segsize@ ( seg# -- u )  >seg hsize@ ;               ( Size of segment seg# in target vocabulary )
: segused@ ( seg# -- u )  >seg hused@ ;               ( Usage of segment seg# in target vocabulary )
: !segfree ( seg# u -- )  >seg !hfree ;               ( Make sure at least u bytes are available in target segment seg# )
: segment ( seg# -- a u )  >seg heap ;                ( Address and length of segment seg# )
: seg→| ( seg# -- a )  >seg >hend ;                   ( Address of the next available byte in segment seg# of target vocabulary )
: >segoffs ( a seg# -- u )  >seg >hend - ;            ( transform address a to an offset in segment seg# of vocabulary @voc )
: tseg#@ ( -- seg# )  targetSegment @ ;               ( Current target segment )
: tseg#! ( seg# -- )  targetSegment ! ;               ( sets the current target segment to seg# )
: target@ ( -- @voc seg# )  tvoc@ tseg#@ ;            ( Current target [vocabulary and segment] )
: >tseg ( -- @sd )  tseg#@ >seg ;                     ( Address of current target segment descriptor )
: tsegaddr@ ( -- a )  >tseg haddr@ ;                  ( Start address of the current target segment )
: tsegsize@ ( -- u )  >tseg hsize@ ;                  ( Size of the current target segment )
: tsegused@ ( -- u )  >tseg hused@ ;                  ( Usage of the current target segment )
: !tfree ( u -- )  >tseg swap !hfree drop ;           ( Make sure at least u bytes are available in the current target segment )
: tseg→| ( -- a )  >tseg >hend ;                      ( Address of the next available byte in the current target segment )
: tseg#↑ ( -- )  tseg#@ >segs ;                       ( save target segment number on segment-stack )
: tseg#↓ ( -- )  segs> tseg#! ;                       ( restore target segment number from segment-stack )
: →tseg#↑ ( seg# -- )  tseg#↑ tseg#! ;                ( save target segment number on segment-stack and switch to seg# )
: tallot, ( # -- )  >tseg  hallot 2drop ;             ( allot # bytes in current target segment )
: 0tallot, ( # -- )  ?dup if  >tseg  0hallot 2drop  then ;    ( allot # bytes of 0 in current target segment )
: talign, ( # -- )                                    ( align current target segment to an even #, typically cell, 4 or 2 )
  tsegused@ over mod dup 0= if  smash  then  − 0tallot, ;
: t, ( x -- )  >tseg h, ;                             ( punch cell x into the current target segment )
: tc, ( c -- )  >tseg hc, ;                           ( punch unsigned byte c into the current target segment )
: tw, ( w -- )  >tseg hw, ;                           ( punch unsigned word w into the current target segment )
: td, ( d -- )  >tseg hd, ;                           ( punch unsigned double word w into the current target segment )
: tf, ( -- F: r -- )  >tseg hf, ;                     ( punch 10byte real number into the current target segment )
: t$, ( $ -- )  >tseg h$, ;                           ( punch $ into the current target segment )
: ta#, ( a # -- )  >tseg ha#, ;                       ( punch byte array at a with length # into the current target segment )
: t#, ( x # -- )  >tseg h#, ;                         ( punch cell x into the current target segment )
: pf, ( x -- )  §DATA →tseg#↑  t,  tseg#↓ ;           ( punch x into parameter field [data segment] )
: #pf, ( x # -- )  §DATA →tseg#↑  t#,  tseg#↓ ;       ( punch # bytes of x into parameter field [data segment] )
: segname ( seg# -- $ )  cells SEGNAMES + @ ;         ( Name of segment seg# )
: segment. ( seg# -- )  segname type$ ;               ( print the name of segment seg# )

: para@ ( @voc n$ -- p$|0 )                           ( look up name n$ in parameter table, return value p$, or 0 if not found )
  swap §PARA >segment heap over +  begin  2dup - while  >r  2dup $$= if  rdrop count + nip exit  then  count + count +  r> repeat
  2drop  drop 0 ;
: !para@ ( @voc n$ -- p$ )                            ( get parameter named n$ and return its value p$, or fail )
  swap §PARA >segment heap over +  begin  2dup - while  >r  2dup $$= if  rdrop count + nip exit  then  count + count +  r> repeat
  2drop  parameter-not-found ;

( Forcembler locations: )
: there  tseg→| ;
: toff  there ;

( select segment )
: >DICT ( @voc -- @dict )  ( §DICT >segment ) ;       ( select dictionary of vocabulary @voc )
: >CODE ( @voc -- @code )  §CODE >segment ;           ( select code segment of vocabulary @voc )
: >DATA ( @voc -- @data )  §DATA >segment ;           ( select data segment of vocabulary @voc )
: >TEXT ( @voc -- @text )  §TEXT >segment ;           ( select text segment of vocabulary @voc )
: >PARA ( @voc -- @para )  §PARA >segment ;           ( select parameter table of vocabulary @voc )
: >RELS ( @voc -- @rels )  §RELS >segment ;           ( select relocation table of vocabulary @voc )
: >SYMS ( @voc -- @syms )  §SYMS >segment ;           ( select symbol table of vocabulary @voc )
: >DEPS ( @voc -- @deps )  §DEPS >segment ;           ( select dependency table of vocabulary @voc )
: >DBUG ( @voc -- @dbug )  §DBUG >segment ;           ( select debug segment of vocabulary @voc )

--- Vocabulary Operations ---

: createVocabulary ( $ -- )                           ( create vocabulary with name $ )
  segments createTable  dup addVTE  dup lastVoc ! →target↑
  §PARA →tseg#↑  c" Name" t$, t$,  c" Model" t$,  1 tc, VOCAMODEL @ tc, tseg#↓ ;
: vocabulary$ ( @voc -- voc$|0 )  c" Name" para@ ;    ( Name voc$ of vocabulary @voc, if defined )
: >voctype ( t -- )  §PARA →tseg#↑  c" Type" t$, 1 tc, tc,  tseg#↓ ;  ( set vocabulary type to t )
: voctype@ ( @voc -- t )  c" Type" !para@ 1+ c@ ;
create FQVOC$  256 allot
: fqvoc$ ( @voc -- fqvoc$ )  FQVOC$ $/                ( Fully qualified name voc$ of vocabulary @voc )
  over c" Package" para@ ?dup if  $>$ '/' ?c+>$  then
  swap c" Name" para@ ?dup unless  vocabulary-has-no-name  then  $+>$ ;
: vocabulary. ( @voc -- )  vocabulary$ type$ ;        ( prints the vocabulary name )
: "vocabulary". ( @voc -- )  vocabulary$ qtype$ ;     ( prints the vocabulary name in double quotes )
:noname vocabulary. ; is printVocabularyName
: findVocabulary ( $ -- @voc | $ 0 )                  ( Vocabulary @voc with name $, or 0 if not found )
  Vocabularies heap cell/ 0 ?do  dup @ vocabulary$ 2 pick $$= if  nip @ unloop exit  then  cell+ loop  zap ;
: vocabulary# ( @voc -- voc# )                        ( Index voc# of vocabulary @voc )
  Vocabularies heap cell/ 0 ?do  2dup @ = if  2drop i unloop exit  then  cell+ loop  drop
  cr ." Vocabulary «" vocabulary. ." » not found!" terminate ;
: vocmodel ( @voc -- u )  c" Model" !para@ 1+ c@ ;    ( Vocabulary model of vocabulary @voc )
create ModulePath  256 allot
create BaseDir$  ," /home/dio/.force/lib" \ 256 allot  s" HOME" getenv dup BaseDir$ c!  BaseDir$ 1+ swap cmove
create Headline$  19621112 d,  version d,  segments d,  0 d,  32 allot  here Headline$ - constant Headline#
variable SegHeader
: moddir ( @voc -- p$ )  ModulePath dup c0!           ( Parent directory p$ of module path )
  BaseDir$ $+>$  '/' ?c+>$  over c" Package" !para@ $+>$ ;
: modpath ( @voc -- p$ )  ModulePath dup c0!          ( Module path p$ of vocabulary @voc )
  BaseDir$ $+>$  '/' ?c+>$  over c" Package" !para@ $+>$  '/' ?c+>$  swap c" Name" !para@ $+>$  c" .4ce" $+>$ ;
: writeSegmentHeader ( @voc #file u -- @voc #file )   ( write the segment usage u )
  >x 2dup swap x> vocuse SegHeader !  SegHeader cell rot write-file throw ;
: writeHeader ( @voc #file -- @voc #file )            ( write the module header for vocabulary @voc to file #file )
  over vocabulary$ count 31 min Headline$ 16 + 2dup c! 1+ swap cmove
  dup Headline$ Headline# rot write-file throw          ( write headline with magic number and version )
  segments 0 do  i writeSegmentHeader  loop             ( write usage and size of each segment )
  segments 1 and if  SegHeader 0!  SegHeader cell 2 pick write-file throw  then ;
: writeSegment ( @voc #file u -- @voc #file )         ( write segment u of vocabulary @voc to file #file )
  >x 2dup swap x> vocseg 16 ->| rot write-file throw ;
: shipVoc ( @voc -- )                                 ( ship vocabulary @voc )
  cr ." Shipping vocabulary " dup "vocabulary". space
  dup moddir count 511 mkdir-parents drop               ( create the intermediate directories )
  dup modpath count w/o create-file throw               ( open a new file with path derived from vocabulary path )
  writeHeader  segments 0 do  i writeSegment  loop      ( write header and all segments )
  ." to " ModulePath qtype$
  close-file throw  2drop ;                             ( close file )
: shipVocabulary ( -- )  targetVoc @ shipVoc ;        ( ship the current target vocabulary )
: tvoc. ( -- )
  cr ." Target Vocabulary: " tvoc@ dup vocabulary$ dup type$  swap ."  @" hex.
  cr ." -------------------" c@ 0 udo  '-' emit  loop
  segments 0 do
    cr i segname 31 over c@ - 0 max 0 udo  '.' emit  loop  space type$ ." : "
    '@' emit  i >seg dup haddr@ hex.  dup hused@ hex. '/' emit  hsize@ hex.  loop ;
: voc. ( @voc -- )
  cr ." Vocabulary " dup vocabulary$ dup type$  swap ."  @" hex.
  cr ." -----------" c@ 0 udo  '-' emit  loop
  segments 0 do
    cr i segname 31 over c@ - 0 max 0 udo  '.' emit  loop  space type$ ." : "
    '@' emit  i >seg dup haddr@ hex.  dup hused@ hex. '/' emit  hsize@ hex.  loop ;
:noname tvoc. ; is printVoc
create LOCALNAME  256 allot
: >localname ( fqvoc$ -- voc$ )  count 2dup '/' cfindlast #+> dup LOCALNAME c!++ swap cmove  LOCALNAME ;


=== Dependencies ===

create DEPENDENCY-NAME  256 allot
variable loadedModule

: depend ( -- )  DEPENDENCY-NAME  loadedModule @ >x   ( make the current target vocabulary depend on the last loaded module )
  cr ." Loaded Module: " x@ "vocabulary".  cr ." Target vocabulary: " tvoc@ "vocabulary".
  x@ c" Package" para@ ?dup unless cr ." Dependency " x> "vocabulary". ."  has no package name!" terminate then $>$ '/' ?c+>$
  x@ c" Name" para@ ?dup unless  cr ." Dependency " x> "vocabulary". ."  has no name property!" terminate then  $+>$
  §DEPS →tseg#↑  t$,  tseg#↓  xdrop ;
: dep# ( $ @voc -- #voc t | $ f )                     ( get dependency index # of vocabulary fqpath $ in vocabulary @voc, if found )
  2dup vocabulary$ $$= if  2drop 0 true exit  then      ( $ is the vocabulary name → index 0 )
  §DEPS vocseg 1 >x begin dup while  -rot 2dup $$= if  2drop drop x> true exit  then  rot over c@ 1+ #+>  x> 1+ >x repeat
  2drop x> drop false ;
: voc# ( @voc -- #voc )  tvoc@ over = if  zap exit  then ( Dependency number of @voc in the current target vocabulary )
  fqvoc$ tvoc@ dep# unless  cr ." Vocabulary " type$ ."  is not a dependency of " tvoc@ vocabulary. terminate  then ;
: @dep ( # -- @voc )  ?dup unless  tvoc@ exit  then   ( #th dependency of the target vocabulary )
  1- §DEPS segment rot 0 udo  ?dup unless  cr ." Requested dependency index does not exist!" abort  then  over c@ 1+ #+>  loop
  drop >localname findVocabulary ?dup unless  cr ." Vocabulary " qtype$ ."  not found!" terminate  then ;



=== Locators ===

------
A locator is a relocatable pointer at a location in a vocabulary, consisting of:
  • a vocabulary index
  • a segment number
  • a segment offset

A pair of locators, one source locator and one target locator, forms a relocation entry ("relocEnt").  In a relocEnt, both
vocabulary indices refer to the dependency table of the source location (0 being the source vocabulary itself).
For a single locator, the vocabulary index transiently refers to the current vocabulary table (0 being the current voc).

The locator type symbol (e.g. in stack effect comments) is ‹&›.
------

--- Locator Structure ---

( Bit offsets )
0000  dup constant LOCATOR.OFFSET                     ( Offset within the segment )
 32 + dup constant LOCATOR.SEGMENT                    ( Segment within the vocabulary. 15 = vocabulary proper )
  4 + dup constant LOCATOR.VOCABULARY                 ( Index of the vocabulary in the vocabulary table )
 12 + dup constant LOCATOR.EXTRA                      ( Extra information, up to 16 bits )
 16 + constant LOCATOR#                               ( Size of a locator in bits )

( Bit masks )
32 bits constant %LOCATOR.OFFSET
 4 bits constant %LOCATOR.SEGMENT
12 bits constant %LOCATOR.VOCABULARY
16 bits constant %LOCATOR.EXTRA

%0000000000000001 constant %CODE-LOCATION             ( Locator refers to a code location [32-bit reloc only] )

-1 constant &null                                     ( The null-locator is equivalent to the null-address [0] )

--- Locator Primitives ---

: >>offset ( & -- u )  %LOCATOR.OFFSET and ;          ( Extracts offset u from locator & )
: >>segment ( & -- seg# )  LOCATOR.SEGMENT u>> %LOCATOR.SEGMENT and ;       ( extract seg# from locator & )
: >>voc# ( & -- voc# )  LOCATOR.VOCABULARY u>> %LOCATOR.VOCABULARY and ;    ( extract vocabulary index voc# from locator & )
: >>@voc ( & -- @voc )  >>voc# @dep ;                                       ( extract vocabulary address @voc from locator & )
: >>extra ( & -- u )  LOCATOR.EXTRA u>> %LOCATOR.EXTRA and ;                ( extract extra info )
: <<extra ( & %u -- &' )                              ( Sets the extra field or locator & to %u )
  %LOCATOR.EXTRA and LOCATOR.EXTRA u<< swap %LOCATOR.EXTRA LOCATOR.EXTRA u<< andn or ;

: !seg# ( seg# -- #seg# )                             ( validate segment number )
  dup §VOCA = over 0 segments within or unless  cr ." Invalid segment index: " . abort  then ;

--- Locator Operations ---

defer reloc,
: &. ( & -- )  dup >>@voc vocabulary. '.' emit  dup >>segment segment. '#' emit >>offset addr. ;  ( print locator & )
: >& ( @voc seg# offs -- & )                          ( create locator from @voc, seg# and offs )
  cr ." >&: Voc=" 2 pick hex. ." , segment=" over . ." , offset=" dup hex.
  dup 32 >> 0- if  cr ." Offset too big: " hex. abort  then
  swap !seg#  LOCATOR.SEGMENT u<< +  swap voc#  LOCATOR.VOCABULARY u<< + ;
: >T& ( seg# offs -- & )  !u4                         ( create locator from target vocabulary, seg# and offs )
  swap !seg#  LOCATOR.SEGMENT u<< + ;
: &> ( & -- @voc seg# offs )  dup >>@voc over >>segment rot >>offset ;    ( explode locator into its components )
: &>a ( & -- a )                                      ( resolve locator & to address )
  dup >>@voc  over >>segment dup §VOCA = if drop  else  addr@  then  swap >>offset + ;
: &seg ( seg# -- & )  swap 0 >T& ;                    ( create locator to start of segment seg# in target vocabulary )
: &seg→| ( seg# -- & )  dup segused@ >T& ;            ( create locator to end of segment seg# in target vocabulary )
: &segoffs ( u seg# -- & )  swap >T& ;                ( create locator for offset u in segment seg# of target vocabulary )
: &tseg ( -- & )  tseg#@ 0 >T& ;                      ( create locator to start of current target segment )
: &tseg→| ( -- & )  tseg#@ &seg→| ;                   ( create locator to end of current target segment )
: &&! ( &s &t -- )  &>a swap &>a ! ;                  ( relocate s to t, full-cell source )
: t&, ( & -- )  &tseg→| over &>a t,  reloc, ;         ( punch & into current target segment and create relocation entry )
: s&, ( & seg# -- )  →tseg#↑  t&,  tseg#↓ ;           ( punch & into target segment seg# and create relocation entry )
: t& ( a seg# -- & )  tuck  segaddr@ - cr ." t&: " 2dup swap segment. ':' emit hex. >T& ;     ( create locator for address a in target segment seg# )
: vt& ( @voc a seg# -- & )  2 pick over addr@ rot r− >& ;   ( create locator for address a in #seg segment of vocabulary @voc )
: withVoc ( @voc &1 -- &2 )  dup >>segment swap >>offset >& ;    ( replace voc# in &1 with @voc )
: +&there ( offs -- & )  tseg#@ swap tsegused@ + >T& ; ( Locator for offset offs from end of current target segment )
: >extra ( & %u -- &' )  over >>extra or <<extra ;    ( add flags %u to locator & )
: &+ ( & off -- &' )  over %LOCATOR.OFFSET and + !u4 swap %LOCATOR.OFFSET andn or ;   ( add off to offset of & )



=== Relocation ===

--- Relation Table Entry Structure ---

0000  dup constant RELOC.SOURCE                       ( Source locator )
cell+ dup constant RELOC.TARGET                       ( Target locator )
cell+     constant RelocEntry#

--- Relocation State ---
variable relocs

--- relocation primitives ---

: relocSource. ( @source -- )                         ( Prints the relocation source )
  dup >>@voc vocabulary. '.' emit  dup >>segment segment. '#' emit  >>offset addr. ;  alias relocTarget.
: _!sourceValid ( &s -- &s )  dup >>segment  §CODE §TEXT within unless  cr ." Invalid source segment: " >>segment segment. abort  then
  dup >>@voc over >>segment vocuse over >>offset u< if  cr ." Out of segment length: " >>offset . abort  then ;
: _!targetValid ( &t -- &t )  dup >>segment  dup §VOCA = swap §DICT §PARA within or unless  cr ." Invalid target segment: " >>segment segment. abort  then
  dup >>@voc over >>segment vocuse over >>offset u< if  cr ." Out of segment length: " >>offset . abort  then ;
: _!valid ( &t &s -- &t &s )                          ( make sure both locators are valid )
  _!sourceValid swap _!targetValid swap ;

--- Relocation Operations ---

:noname ( &t &s -- )  _!valid §RELS →tseg#↑ t, t, tseg#↓ ; is reloc,  ( Add relocation with source &s and target &t to relocation table )
: codereloc, ( &t &s -- )  cr %CODE-LOCATION >extra reloc, ;
: relocs. ( -- )  §RELS >seg heap RelocEntry# u/ 0 udo    ( Prints the relocation table )
  cr dup RELOC.SOURCE + @ relocSource.  space ." -> "  dup RELOC.TARGET + @ relocTarget.  RelocEntry# +  loop  drop ;
: reloc ( @rel -- )  dup RELOC.SOURCE + @  swap RELOC.TARGET + @ &&! ;
: relocate ( @voc -- )  dup §RELS vocseg 0 udo        ( relocate vocabulary @voc )
  dup reloc  RelocEntry# tuck +  swap +loop  2drop ;

variable DATASEG#
variable CODESEG#
: _fixreloc ( & -- &' )  dup >>segment case
    §CODE of  CODESEG# @  endof
    §DATA of  DATASEG# @  endof
    cr ." Cannot resolve relocation to " segment. '!' emit  0 endcase
  &+ ;
: insert-compact-voc ( @voc -- )                      ( copy the words of vocabulary @voc into the current target vocabulary )
  cr ." Copying code segment ..." §CODE segused@ CODESEG# !  §CODE →tseg#↑  dup §CODE vocseg ta#,  tseg#↓
  cr ." Copying data segment ..." §DATA segused@ DATASEG# !  §DATA →tseg#↑  dup §DATA vocseg ta#,  tseg#↓
  cr ." Adjusting relocations ..." §RELS →tseg#↑  §RELS vocseg  RelocEntry# u/ 0 udo  @++ _fixreloc t,  @++ _fixreloc t,  loop  drop  tseg#↓
  cr ." Insertion done." ;
: insert-structured-voc ( @voc -- )                   ( copy the words of vocabulary @voc into the current target vocabulary )
  ***TODO*** ;



=== Search Order ===

newHeap SearchOrder

: addSearchVoc ( @voc -- )  SearchOrder h, ;          ( append vocabulary @voc to the search order => "also @voc" )
: previousOrder ( -- )  cell SearchOrder hused−! ;    ( remove last search order entry => previous )
: removeSearchVoc ( @voc -- )                         ( remove last occurrence of vocabulary @voc from the search order )
  SearchOrder -heap cell/ 0 ?do  cell− dup @ 2 pick = if
    dup cell+ swap i move  cell SearchOrder hused−!  drop unloop exit  then  loop
  drop cr ." Warning: vocabulary «" vocabulary. ." » not found in search list! ⇒ not removed." ;
: primary ( -- @voc|0 )                               ( Last = primary search list entry, or 0 if none )
  SearchOrder hempty? if  0  else  SearchOrder >hend  cell- @  then ;
: searchlist. ( -- )                                  ( print the search order )
  cr ." Search order:"
  SearchOrder heap cell/ 0 ?do  dup @  cr ." • " dup vocabulary.  targetVoc @ = if  space ." *"  then  cell+  loop  drop ;



=== Directory and File Handling ===

create LOCAL-USER ," ~/.force/"
create LOCAL-SYSTEM ," /usr/force/"
create DIRECTORY-NAME  256 allot
create FILE-BUFFER  256 allot
create CURRENT-FILE  256 allot
create FOUND-FILE  256 allot
variable #FOUND-FILES

: file-exists? ( $ -- ? ) count file-status nip 0= ;  ( check if file $ exists )
: directory? ( $ -- ? )                               ( test, using a trick, if $ is a directory name: gforth has no stat-file )
  DIRECTORY-NAME swap $>$  '/' ?c+>$  c" .." $+>$ file-exists? ;  ( does an entry $/.. exist? then it's a directory )
: find-file ( $1 $p -- $2 t | $1 f )  #FOUND-FILES 0!  ( lookup file $1 in path $p and return absolute path $2 if found )
  dup directory? unless  drop false exit  then  dup >x  count open-dir throw  >x
  begin  FILE-BUFFER 1+ 255 x@ read-dir throw  while
    FILE-BUFFER c!  CURRENT-FILE 2x@ $>$ '/' ?c+>$ FILE-BUFFER $+>$  cr ." >> " type$
    CURRENT-FILE over $$=<| if  FOUND-FILE CURRENT-FILE $>$ drop  #FOUND-FILES 1+!  then
    repeat
  x> xdrop close-dir throw  #FOUND-FILES @ case
    0 of  endof
    1 of  2drop  FOUND-FILE true  endof
    #FOUND-FILES has-multiple-results  0 endcase ;
: lookup-file ( $1 -- $2 t | $1 f )                   ( lookup file $1 in the package tree, return absolute path $2 if found )
  LOCAL-USER find-file  ?dup unless  LOCAL-SYSTEM find-file  then ;



=== Module Management ===

------
• A module is a compiled vocabulary snapshot residing in a binary file within the package tree.
• A module name can be a simple name like "CoreMacro" [referring to file "CoraMacro.4ce" anywhere in the package tree],
  a partial path like "macro/CoreMacro", or a full path like "force/intel/64/macro/CoreMacro".  The module that gets loaded
  is from the specified path, extended with .4ce/.4th, whose full path is the longest string ending with the path.
• The package tree has two local roots: the system root, usually starting with "/usr/force/", and the user root,
  usually starting with "~/.force/".  The user root is searched first; if no match is found, the system root is searched.
  Both roots have exactly the same substructure.
• The package tree can have an arbitrary number of source and module repository roots represented as base URIs, e.g.
  git@github.com:freedio/FORCE or https://repo.maven.apache.org/maven2#com.coradec:force:1.1 — each of them is consulted
  in the order specified in the extended package tree specification, if the local roots yield nothing.  The repository roots
  have exactly the same substructure as the local roots.
• Each root has 5 top-level entries called branches:
  · src/ contains the sources (.4th)
  · lib/ contains the modules (.4ce)
  · bin/ contains the executables (.exe for ms-win, no extension for linux), most notably the FORCE Core ('force[.exe]')
  · etc/ contains configuration files (.4cf)
  · man/ contains the documentation (.4cd)
• A module is first looked up in the lib/ branch; if no matching module is found, the src/ branch is searched next; if none
  is found here, the loader tries other roots until it finds a module, then gives up.
• Modules have a build timestamp and a reference to the source which they were built from.  When a module is opened, the build
  timestamp is compared to the source file last-modified date; if the source is newer, the source is loaded instead.  If, for
  whatever reason, the source file is inaccessible or the last-modified date cannot be determined on it, the module is just
  loaded as is.
• Source files are always the ultimate reference to the code —  modules are only convenience snapshots to avoid the cost
  of repeated compilation (which is much cheaper than in other languages, but still ...).
------

--- Module State ---

create MODULE-HEADER  256 allot

--- Module Primitives ---

defer sourceModule

create SourcePath  256 allot

create FiletimeBfr  64 allot
create FiletimeCmd  300 allot
: failed-to-decode ( a # -- )  cr FiletimeBfr qtype$ ."  is not a full ISO filedatetime @ " type  terminate ;
: digs ( a # u -- a' #' X: x -- x' )                ( reads u digits from buffer a# post-advance and add to x )
  0 udo  dup 0= if  failed-to-decode  then  over c@ '0' -  x> 10 * + >x  +>  loop ;
: skip ( a # c -- a' #' )  2 pick c@ = unless  failed-to-decode  then  +> ;    ( skip character c in buffer a# )
: getFileTime ( $ -- u )  FiletimeCmd
  c" (ls --full-time " $>$  swap $+>$  c" | awk '{ print $6 " $+>$  '"' c+>$  $20 c+>$  '"' c+>$  c" $7 }') > /tmp/% 2> /dev/null" $+>$  count system
  0 >x s" /tmp/%" slurp-file ?dup unless  drop 0 exit  then  1-  2dup FiletimeBfr -rot  a#>$ drop
  4 digs '-' skip 2 digs '-' skip 2 digs $20 skip 2 digs ':' skip  2 digs ':' skip  2 digs '.' skip  5 digs 2drop x> ;
: date. ( u -- )  s>d <# # # # # # '.' hold # # ':' hold # # ':' hold # # 'T' hold # # '-' hold # # '-' hold # # # # #> type ;

: skip/ ( $ -- a # )  count  over c@ '/' = over 0- and if  +>  then ;
variable file
: ?loadModule ( $1 $2 -- ? )                        ( try loading module $1 from root $2 and report if successful )
  ModulePath over 1+ c@ '~' = if  s" HOME" getenv a#>$ swap count +> a#+>$  else  swap $>$  then
(  cr ." ?loadModule: ModulePath 1: " ModulePath dup qtype$ space '@' emit hex. )
  SourcePath over $>$
(  cr ." ?loadModule: SourcePath 1: " SourcePath dup qtype$ space '@' emit hex. )
  '/' ?c+>$  c" src/" $+>$  2 pick skip/ a#+>$  c" .4th" $+>$  getFileTime
(  cr ." ?loadModule: SourcePath 2: " SourcePath qtype$ ." , source file time: " dup . )
  swap '/' ?c+>$  c" lib/" $+>$  rot skip/ a#+>$  c" .4ce" $+>$  getFileTime
(  cr ." ?loadModule: ModulePath 2: " ModulePath qtype$ ." , module file time: " dup . )
  ?dup unless  cr ." Module " ModulePath qtype$ ."  does not exist"  zap exit  then
  u> if  cr ." Source is newer: module " ModulePath qtype$ ."  rejected in favor of source!" false exit  then
  ModulePath cr ." Loading module "  dup qtype$  count r/o open-file ifever  ."  failed (to open)." exit  then  file !
  MODULE-HEADER 128 tuck file @ read-file throw = unlessever  ."  failed (to read header)" 0 else
    MODULE-HEADER Headline$ 16 tuck compare ifever  ."  failed: incompatible headers" 0 else
      MODULE-HEADER 16 + cr ." → vocabulary " dup qtype$  createVocabulary xdepth
      MODULE-HEADER Headline# + segments 0 do           ( read segments )
        ." , "  i segname type$ dup @ ?dup if  ."  (" dup . ." B)"
          dup lastVoc @ i >segment hset over 16 ->| file @ read-file throw swap 16 ->| - ifever
            ."  failed (EOF)!" terminate  then  then
        cell+ loop  drop  then  then
  ." : loaded"
  lastVoc @ relocate  ." , relocated"
  file @ close-file throw  lastVoc @ addSearchVoc  ." , added to searchlist." ;
: ?loadSource ( $1 $2 -- ? )                          ( try loading module $1 from root $2 and report if successful )
  ModulePath over 1+ c@ '~' = if  s" HOME" getenv a#>$  swap count +> a#+>$  else  swap $>$  then
  '/' ?c+>$  c" src/" $+>$  swap skip/ a#+>$  c" .4th" $+>$  cr ." Reading source file "  dup qtype$
  dup count r/o open-file ifever  ."  failed (to open)."  drop zap exit  then  close-file throw  sourceModule true ;

--- Module Methods ---

create MODULE-NAME  256 allot
create MODULE-PATH  256 allot
create MODULE-PATH2 512 allot
: loadModule ( $ -- )  MODULE-PATH swap $>$           ( load the module with name $ )
  cr ." Searching for vocabulary " dup qtype$ count '/' cxafterlast dup MODULE-NAME c!++ swap cmove  space '(' emit MODULE-NAME type$ ')' emit
  MODULE-NAME findVocabulary ?dup if  dup loadedModule !  cr ." Vocabulary " vocabulary. ."  already loaded."  exit  then
  drop lastVoc @ targetVoc @
  MODULE-PATH dup c@ 0- swap 1+ c@ '/' = and if         ( absolute module name )
    MODULE-PATH c" ~/.force" ?loadModule unless
    MODULE-PATH c" ~/.force" ?loadSource unless
    MODULE-PATH c" /usr/force" ?loadModule unless
    MODULE-PATH c" /usr/force" ?loadSource unless
    MODULE-PATH module-not-found-in-package-tree
    then then then then  else                           ( relative module name: prefix with current package )
  currentPackage c@ if
    MODULE-PATH2 currentPackage $>$ '/' ?c+>$ MODULE-PATH $+>$ c" ~/.force" ?loadModule unless
    MODULE-PATH2 c" ~/.force" ?loadSource unless
    MODULE-PATH2 c" /usr/force" ?loadModule unless
    MODULE-PATH2 c" /usr/force" ?loadSource unless
    MODULE-PATH2 module-not-found-in-package-tree
    then then then then  else  MODULE-PATH module-not-found-in-package-tree  then  then
  lastVoc @ loadedModule !  targetVoc ! lastVoc ! ;



=== Vocabulary Entry (Word) Management ===

( @w is the address of a word.  For compact vocabularies: the code field; for structured: the dictionary entry.
  @word is the origin of a word, i.e. the address of the flag field.
)

--- Word Structure of Structured Vocabularies ---

0000  dup constant sFLAGS
cell+ dup constant sNFA
cell+ dup constant sCFA
cell+ constant sWORD#
( Optional PFA [if flag WITH-PFA is set], with optional alignment bytes [if flag ALIGN-PFA is set], follows the name field. )

--- Word Structure of Compact Vocabularies ---

( WORD        cFLAGS
  BYTE        cNF#
  cNF# BYTES  cNF
 *BYTES       cPFX  [alignment to next cell address]
 *CELL        cPFA  [if flag WITH-PFA is set]
 *BYTES       cCFX  [alignment to next word address]
  WORD        cCF#
  cCF# BYTES  cCF
 *BYTES       cLENX [alignment to next word address]
  WORD        cLEN
)

--- Word Flags ---

%0000000000000011 constant %EXECTYPE                  ( Execution type: 0 = inline, 1 = direct, 2 = indirect, 3 = token )
%0000000000001100 constant %VISIBILITY                ( Visibility: 0 = private, 1 = protected, 2 = package, 3 = public )
%0000000000000000 constant %PRIVATE                   ( Visibility: private )
%0000000000000100 constant %PROTECTED                 ( Visibility: protected )
%0000000000001000 constant %PACKAGE                   ( Visibility: package private )
%0000000000001100 constant %PUBLIC                    ( Visibility: public )
%0000000000110000 constant %CODETYPE                  ( Code type: 0 = method, 1 = destructor, 2 = constructor, 3 = cascaded cstr. )
%0000000000000000 constant %METHOD                    ( Code type: method )
%0000000000010000 constant %DESTRUCTOR                ( Code type: destructor )
%0000000000100000 constant %CONSTRUCTOR               ( Code type: constructor )
%0000000000110000 constant %CASCADED                  ( Code type: cascaded constructor )
%0000000001000000 constant %WITH-PFA                  ( Word has a parameter field address )
%0000000010000000 constant %RELOCS                    ( Code field contains relocations )
%0000000100000000 constant %MAIN                      ( Module entry point )
%0000001000000000 constant %STATIC                    ( Static )
%0000010000000000 constant %INDIRECT                  ( There is an absolute jump address instead of the code field )
%0000010000000000 constant %ABSTRACT                  ( Abstract method: %INDIRECT + CFA=0 )
%0000100000000000 constant %CONDITION                 ( Word is a condition usable in conditional clauses )
%0001000000000000 constant %INLINE                    ( Word is inline, i.e. code copied instead of called )
%0010000000000000 constant %JOIN                      ( Word is an inline-joiner )
%0100000000000000 constant %LINK                      ( Word is an inline-linker )
%1000000000000000 constant %FALLIBLE                  ( Word can produce an exception state )

( Linker and Joiner:
  - a joiner's first instruction is SAVE TOP − without even a [invisible] BEGIN preceding it.
  - a linker's last instruction is RESTORE TOP − without even a [invisible] THEN following it.
  - both conditions cannot be determined from the final code alone due to the mentionned strong conditions and the fact that
    PUSH TOP and SAVE TOP as well as DROP TOP and RESTORE TOP have the same appearance.
  - if a joiner follows a linker immediately, the SAVE / RESTORE pair "between them" can be dropped.
  - This condition appears quite frequently and may therefore save a lot of space and time.
)

variable autoFlags                                    ( Flags that get set on creating each word )
variable nextFlags                                    ( Flags that get set on creating the next word )
variable wordComplete                                 ( whether code field has already been added to the current word )
variable mayLink                                      ( whether next word's JOIN property can be copied )
variable @lastWord                                    ( Address of last word )
variable #INLINED                                     ( Number of already inlined references )
variable LAST_COMP                                    ( Last word compiled into the code )

--- Word Primitives ---

: LAST_COMP0! ( -- )  LAST_COMP 0! ;
: currentWord@ ( -- @w )  @lastWord @ ?dup unless  cr ." There is no current word!" terminate  then ;
: flags ( @word -- @word u )  dup w@ ;                ( Flags of word @word )
: flags+! ( %u @word -- )  wor! ;                     ( Set bit mask u as flags in word @word )
: >cpfa ( @word -- a|0 )  flags %WITH-PFA and if      ( Address of PFA of compact word, or 0 if no PFA defined )
  2 + count + cell ->|  else  drop 0  then ;
: >spfa ( @word -- a|0 )  flags %WITH-PFA and if      ( Address of PFA of structured word, or 0 if no PFA defined )
  cell+ @ count +  else  drop 0  then ;
: >ccf ( @word -- a )  flags %INDIRECT and >x         ( Address of code field of compact word )
  dup 2 + count +  swap d@ %WITH-PFA and if  cell ->| cell+  then  x> if  cell ->| @  else  2 ->| 2 +  then ;
: &ccfa ( @voc @word -- &cfa )                        ( Reference to CFA of compact word @word in vocabulary @voc )
  >ccf over §CODE addr@ - §CODE swap >& ;
: &ccf ( @voc @word -- &cf )                          ( Reference to code field of compact word @word in vocabulary @voc )
  flags swap >ccf swap %INDIRECT and if  @  else  2+  then  §CODE vt& ;
: &scfa ( @voc @word -- &cfa )                        ( Reference to CFA of structured word )
  2 cells+ @ §CODE swap >& ;
: &cpfa ( @word -- &pfa|-1 )                          ( Reference to PFA of compact word, or -1 if PFA not set )
  flags %WITH-PFA and unless  drop -1 exit  then
  2 + count + cell ->| @ §DATA t& ;
: &spfa ( @word -- &pfa|-1 )                          ( Reference to PFA of structured word, or -1 if PFA not set )
  flags %WITH-PFA and unless  drop -1 exit  then
  sNFA + @ count + cell ->| @ §DATA t& ;
: >cnext ( @word -- @word' )                          ( Skip to next word from compact word @word )
  dup >x 2 + count +                                  ( skip flags and name )
  x@ d@ %WITH-PFA and if  cell ->| cell+  then        ( skip PFA if present )
  x> d@ %INDIRECT and if  cell ->| cell+  else  2 ->| dup w@ 2+ +  then    ( skip CF )
  2 ->| 2 + ;
: >snext ( @word -- word' )  3 cells+ ;               ( Skip to next word from structured word @word )
: cword$ ( @word -- $ )  2 + ;                        ( Name of compact word )
: sword$ ( @word -- $ )  sNFA + @ ;                   ( Name of structured word )

--- Word Operations ---

( CFA locator: )
: &CFA ( @voc @word -- &cfa )  over vocmodel case     ( CFA locator for word @word in vocabulary @voc )
    COMPACT-VOC of  &ccfa  endof
    STRUCTURED-VOC of  &scfa  endof
    unknown-vocabulary-model  endcase ;

( PFA locator: )
: &PFA ( @voc @word -- &pfa )  swap vocmodel case     ( PFA locator for word @word in vocabulary @voc )
    COMPACT-VOC of  &cpfa  endof
    STRUCTURED-VOC of  &spfa  endof
    unknown-vocabulary-model  endcase ;

( name of word: )
: structName, ( a$ -- & )                             ( punch a$ into text segment of target word and return its locator )
  §TEXT →tseg#↑  t$,  tseg#↓ ;
: word$ ( @voc @word -- $ )  swap vocmodel case       ( Name of word @word in vocabulary @voc )
    COMPACT-VOC of  cword$  endof
    STRUCTURED-VOC of  sword$  endof
    unknown-vocabulary-model  endcase ;

( create word: )
: createCompactWord ( a$ -- )                         ( create compact word with name a$; only flags and name are allocated! )
  §CODE →tseg#↑  tseg→| @lastWord !  nextFlags @ tw,  t$,  tseg#↓ ;
: _createStructuredWord ( &cfa a$ -- )                ( create structured word with name a$ and CFA &cfa )
  structName, §DICT →tseg#↑  tseg→| @lastWord !  nextFlags @ t, t&, t&,  tseg#↓ ;
: createStructuredWord ( a$ -- )  §CODE &seg→| swap _createStructuredWord ;
: createWord ( a$ -- )  wordComplete 0!  #INLINED 0!  ( create word with name a$ )
  VOCAMODEL @ case
    COMPACT-VOC of  createCompactWord  endof
    STRUCTURED-VOC of  createStructuredWord  endof
    unknown-vocabulary-model  endcase
  autoFlags @ nextFlags ! ;

( punch PFA: )
: #PFA, ( &pfa -- )                                   ( add a parameter field address with &pfa to the word )
  dup &null = if  drop exit  then       ( &pfa null ⇒ silently ignore )
  currentWord@ d@ %WITH-PFA and 0-  wordComplete @ or if  ( word complete, or no pfa ⇒ complain )
    drop  cr ." Out-of-sequence PFA declaration: PFA present or current word already complete!" terminate  then
  VOCAMODEL @ case
    COMPACT-VOC of  §CODE  endof
    STRUCTURED-VOC of  §TEXT  endof
    unknown-vocabulary-model  endcase
  →tseg#↑  cell talign,  t&,  tseg#↓  %WITH-PFA currentWord@ dor! ;
: PFA, ( -- )  §DATA &seg→|  #PFA, ;                  ( add a parameter field address with the current DATA offset )

( create alias: )
: createIndirectAlias ( a$ @word -- )                 ( create alias for indirect word )
  flags nextFlags !                                     ( copy flags )
  §CODE seg→| >r                                        ( save current length of code segment )
  swap  createCompactWord                               ( create word )
  dup &cpfa #PFA,                                       ( copy PFA, if present )
  dup >ccf §CODE t&  §CODE →tseg#↑  cell talign,  t&,   ( copy CFA )
  cell talign,  4 + r> r− !uword tw,                    ( punch word length )
  tseg#↓ ;
: createCompactAlias ( a$ -- )                        ( create alias for last word )
  currentWord@ flags %INDIRECT and if  createIndirectAlias  exit  then    ( handle indirect target separately )
  flags %INDIRECT or nextFlags !                        ( copy flags )
  §CODE seg→| >r                                        ( save current length of code segment )
  swap  createCompactWord                               ( create word )
  dup &cpfa #PFA,                                       ( copy PFA, if present )
  §CODE →tseg#↑  tvoc@ over &ccfa  cell talign,  t&,    ( insert indirection to original CFA )
  cell talign,  8 + r> r− !uword tw,                    ( punch word length )
  tseg#↓ ;
: createStructuredAlias ( a$ -- )                     ( create alias for last word )
  currentWord@ flags nextFlags !                        ( copy flags )
  dup &scfa rot createStructuredWord                    ( create word with same CFA )
  &spfa #PFA, ;                                         ( copy PFA, if present )
: createAlias ( a$ -- )  VOCAMODEL @ case             ( create an alias of the last word with name a$ )
    COMPACT-VOC of  createCompactAlias  endof
    STRUCTURED-VOC of  createStructuredAlias  endof
    unknown-vocabulary-model  endcase
  autoFlags @ nextFlags ! ;

( create definition: )
: createCompactDef ( a$ -- )                          ( create compact definition )
  %ABSTRACT nextFlags or!                               ( copy flags )
  §CODE seg→| >r                                        ( save current length of code segment )
  createCompactWord  §CODE →tseg#↑   cell talign,  0 t, ( insert 0 code CFA )
  cell talign,  there 2+ r> - !uword tw,  tseg#↓ ;
: createStructuredDef ( a$ -- )                       ( create structured definition )
  ***TODO*** ;
: createDef ( a$ -- )  VOCAMODEL @ case               ( create an alias of the last word with name a$ )
    COMPACT-VOC of  createCompactDef  endof
    STRUCTURED-VOC of  createStructuredDef  endof
    unknown-vocabulary-model  endcase
  autoFlags @ nextFlags ! ;

( find word: )
: findCompactWord ( $ @voc -- @word t | $ f )         ( look up compact word $ in vocabulary @voc )
  0 >r                          ( nothing found yet )
  §CODE >segment dup >hend >x   ( save end-of-segment address on x-stack )
  haddr@ begin  dup x@ u< while ( while not at end: compare and register if matches )
    2dup 2 + $$= if  rdrop dup >r  then  >cnext  repeat
  x> 2drop  r> dup if  nip true  else  drop false  then ;
: findStructuredWord ( $ @voc -- @word t | $ f )      ( look up sructured word $ in vocabulary @voc )
  0 >r                          ( nothing found yet )
  dup §DICT >segment >hend >x   ( save end-of-segment address on x-stack )
  begin  dup x@ u< while        ( while not at end: compare and register if matches )
    2dup sNFA + @ $$= if  rdrop dup >r  then  >snext  repeat
  x> 2drop  r> dup if  nip true  else  drop false  then ;
: findLocalWord ( $ @voc -- @word t | $ f )           ( look up word $ in vocabular @voc, returning its word address if found )
  dup vocmodel case
    COMPACT-VOC of  findCompactWord  endof
    STRUCTURED-VOC of  findStructuredWord  endof
    unknown-vocabulary-model  endcase ;
: findWord ( $ -- @voc @word t | $ f )                ( find word $ in search order, returning its voc and word address )
  SearchOrder -heap cell/ 0 do
    cr ." Looking up word in " dup cell- @ "vocabulary".
    cell− dup @ 2 pick over findLocalWord if  2swap 2drop true unloop exit  then  2drop  loop
  drop false ;

( punch word: )
: compactWord, ( @voc @word -- )                      ( punch compact word @word in @voc into target code segment )
  dup LAST_COMP !  &ccf withVoc §CODE s&, ;
: structuredWord, ( @voc @word -- )  §DICT t& withVoc §CODE s&, ;    ( punch structured word in @voc into target code segment )
: word, ( @voc @word -- )          ( punch word @word in vocabulary @voc into target code segment )
  flags %JOIN and mayLink @ and if  %JOIN over flags+!  then  mayLink off
  dup vocmodel case
    COMPACT-VOC of  compactWord,  endof
    STRUCTURED-VOC of  structuredWord,  endof
    unknown-vocabulary-model  endcase ;

( print word: )
: printFlags ( flags -- )
  cr ." Flags: "
  dup %VISIBILITY and case
    %PRIVATE of  ."  • private"  endof
    %PROTECTED of  ."  • package private"  endof
    %PACKAGE of  ."  • package private"  endof
    %PUBLIC of  ."  • public"  endof  endcase
  dup %STATIC and if  ."  • static"  else  ."  • dynamic"  then
  dup 3 and case
    0 of  ."  • code threaded"  endof
    1 of  ."  • direct threaded"  endof
    2 of  ."  • indirect threaded"  endof
    3 of  ."  • token threaded"  endof
    endcase
  dup %FALLIBLE and if  ."  • fallible"  then
  dup %INLINE and if  ."  • inline"  then
  dup %JOIN and if  ."  • joiner"  then
  dup %LINK and if  ."  • linker"  then
  dup %MAIN and if  ."  • main"  then
  dup %CODETYPE and case
    %METHOD of  ."  • method"  endof
    %DESTRUCTOR of  ."  • destructor"  endof
    %CONSTRUCTOR of  ."  • constructor"  endof
    %CASCADED of  ."  • cascaded constructor"  endof  endcase
  dup %INDIRECT and if  ."  • alias"  then
  dup %CONDITION and if  ."  • condition"  then
  dup %WITH-PFA and if  ."  • with PFA"  then
  dup %RELOCS and if  ."  • with relocations"  then
  drop ;
: printCompactAlias ( @word -- )                      ( print information about compact alias )
  cr ." Compact alias @" dup hex.
  flags dup printFlags                            ( print flags )
  swap 2+ cr ." Name: "  dup qtype$               ( print name )
  count + swap %WITH-PFA and if                   ( print PFA )
    cell ->| dup @ cr ." PFA: " hex.  cell+  then
  cell ->| dup @ cr ." Code: " dup 2- w@ bare-hexline    ( print code )
  cell+ 2 ->| cr ." Word Length: " w@ . ;         ( print word length )
: printCompactWord ( @word -- )                       ( print information about compact word )
  flags %INDIRECT and if  printCompactAlias exit  then
  cr ." Compact word @" dup hex.
  flags dup printFlags                            ( print flags )
  swap 2+ cr ." Name: "  dup qtype$               ( print name )
  count + swap %WITH-PFA and if                   ( print PFA )
    cell ->| dup @ cr ." PFA: " hex.  cell+  then
  2 ->| cr ." Code: " dup 2+ over w@ bare-hexline ( print code )
  dup 2+ swap w@ + 2 ->| cr ." Word Length: " w@ . ;    ( print word length )
: printStructuredWord ( @ word -- )                   ( print information about structured word )
  cr ." Structured word @" dup hex.
  flags dup printFlags                            ( print flags )
  over sNFA + dup @  cr ." Name: " qtype$         ( print name )
  %WITH-PFA and if                                ( print PFA )
    dup sNFA + @ count + cell ->|  cr ." PFA: " hex.  then
  sCFA + @ cr ." Code: " dup 2+ swap w@ bare-hexline ;    ( print code )
: word. ( @voc @word -- )  swap vocmodel case         ( print information about word @word in vocabulary @voc )
    COMPACT-VOC of  printCompactWord  endof
    STRUCTURED-VOC of  printStructuredWord  endof
    unknown-vocabulary-model  endcase ;



=== Code Generator ===

defer compile,
defer str,
needs MacroForcembler.gf

0 CONSTANT INLINED              ( Create inlined code )
1 CONSTANT INDIRECT-THREADED    ( Create indirect threaded code )
2 CONSTANT DIRECT-THREADED      ( Create direct threaded code )
3 CONSTANT TOKEN-THREADED       ( Create token threaded code )
INLINED =variable CODE-MODEL
: code-model@ ( -- cm ) CODE-MODEL @ ;
: code-model! ( cm -- ) CODE-MODEL ! ;

variable TRIM                                         ( Number of bytes to trim at the beginning of the code )
variable LASTCONTRIB                                  ( Last word added to the compiled code [inline only] )
variable @FORCEMBLER                                  ( Forcembler vocabulary )
variable @COMP-WORDS                                  ( Compiler wordlist / vocabulary )

: compExec ( a$ -- )  cr ." Compexec " dup qtype$  dup count @COMP-WORDS @ search-wordlist if  nip    ( execute compiler word a$ )
    depth 1- 0 max dup >B [ also Forcembler ] ADP+ execute B> ADP- [ previous ] exit  then
  cr ." Compiler word " qtype$ space ." not found!"  terminate ;

: code-range ( @word -- a # )                         ( Determine the code range w/o length, enter and exit code )
  >ccf dup 2 - w@ ENTER# #+> EXIT# − TRIM @ #+> ;
: code# ( @word -- # )  code-range nip ;
: _r, ( ΔC @rel -- )  tuck @ swap  &+  t, RELOC.TARGET + @ t, ;    ( append relocation @rel, source-shifted by ΔC )
: inline-reloc, ( @word a -- )  §RELS →tseg#↑         ( Duplicate relocations of @word, biased to base a )
  over >ccf ENTER# + −  swap code-range over + §CODE segaddr@ tuck − -rot − swap  §RELS segment RelocEntry# / 0 ?do
    dup RELOC.SOURCE + @ >>offset 2over within if  3 pick over _r,  then  RelocEntry# + loop  4 #drop
  tseg#↓ ;
( TODO ?inline-join is machine-specific, so should be moved into machine-code vocabulary )
: ?inline-join ( @word -- @word )  LASTCONTRIB @ ?dup if  flags nip %LINK and if
  flags %JOIN and if  there 1- c@ $58 ( RAX POP ) = if  dup >ccf ENTER# + c@ $50 ( RAX PUSH ) = if
    1 dup TRIM !  §CODE >seg hused−!  then  then  then  then  then ;
: ?>joiner ( @word -- @word )  #INLINED @ unless  flags %JOIN and if  %JOIN currentWord@ flags+!  then  then ;
: ?>linker ( @word -- @word )  #INLINED @ unless  flags %LINK and if  %LINK currentWord@ flags+!  then  then ;
: inline-call, ( @voc @word -- )  cr ." Inline call: " &CFA dup hex. &CALL, ;
: inline-copy, ( @voc @word -- )  ?>linker  ?>joiner  ?inline-join  there >x  nip dup code-range ta#,  x> inline-reloc,  TRIM 0! ;

: int-indirect, ( n -- )  indirect-threading-not-supported ;
: int-direct, ( n -- )  c" lit" findWord if  §CODE →tseg#↑  word, t,  tseg#↓  else  word-not-found  then ;
: int-token, ( n -- )  token-threading-not-supported ;
: int-inline, ( n -- )  dup -1 = if  drop c" lit-1"  else  dup nsize case
  0 of  drop c" lit0"  endof
  1 of  dup 0< if  c" lit1"  else  c" ulit1"  then  endof
  2 of  dup 0< if  c" lit2"  else  c" ulit2"  then  endof
  4 of  dup 0< if  c" lit4"  else  c" ulit4"  then  endof
  8 of  dup 0< if  c" lit8"  else  c" ulit8"  then  endof
  cr ." Invalid literal size: " . terminate  endcase  then
  compExec ;
: float-indirect, ( -- F: r -- )  indirect-threading-not-supported ;
: float-direct, ( -- F: r -- )  c" litf" findWord if  §CODE →tseg#↑  word, f,  tseg#↓  else  word-not-found  then ;
: float-token, ( -- F: r -- )  token-threading-not-supported ;
: float-inline, ( -- F: r -- )  c" litf" compExec ;
: string-indirect, ( &$ -- )  indirect-threading-not-supported ;
: string-direct, ( &$ -- )  c" lit$" findWord if  §CODE →tseg#↑ word, t&,  tseg#↓  else  word-not-found  then ;
: string-token, ( &$ -- )  token-threading-not-supported ;
: string-inline, ( &$ -- )  c" lit$" compExec ;
: word-indirect, ( @voc @word -- )  indirect-threading-not-supported ;
: word-direct, ( @voc @word -- )  §CODE →tseg#↑ word, t&,  tseg#↓ ;
: word-token, ( @voc @word -- )  token-threading-not-supported ;
: word-inline, ( @voc @word -- )
  dup >r flags %INLINE and over code# 16 < or if inline-copy, else inline-call, then #INLINED 1+! r> dup LASTCONTRIB ! LAST_COMP ! ;
: voc-indirect, ( @voc -- )  indirect-threading-not-supported ;
: voc-direct, ( @voc -- )  c" vocabulary" findWord if  §CODE →tseg#↑ word, t&,  tseg#↓  else  word-not-found  then ;
: voc-token, ( @voc -- )  token-threading-not-supported ;
: voc-inline, ( @voc -- )  c" vocabulary" compExec ;

: resolveExxit ( ae a -- ae )  2dup - swap 4- d! ;  ( Resolves EXXIT at address a to actual exit at ae )
: resolveExxits ( -- )              ( Resolves all the unresolved EXXITs on the X stack; without reloc, as inside same method )
  §CODE seg→|  YDEPTH 0 ?do  Y> resolveExxit  loop  drop ;



=== Input Stream ===

--- Source Buffer ---

variable @BUFFER                    ( Address of the input buffer )
variable CURSOR                     ( Input buffer cursor )
variable LENGTH                     ( Input buffer length )
variable FILEID                     ( Current source file ID )
variable @FILENAME                  ( Address of the current source file name )
variable @NEXTCHAR                  ( Address of appropriate nextChar routine )

variable @FILENEXTCHAR              ( Address of the file nextChar )
variable @CONSNEXTCHAR              ( Address of the console nextChar )

: closeFile ( -- )  FILEID dup @ ?dup if
  close-file throw  then  0!    ( close current file and free associated buffers )
  @BUFFER dup @ ?dup if  free throw  then  0!  @FILENAME dup @ ?dup if  free throw  then  0! ;
: openFile ( a$ -- )  dup c@ 1+  dup allocate throw  dup @FILENAME !  swap cmove    ( open file with specified name )
  @FILENAME @ count r/o open-file throw FILEID !  CURSOR 0!  LENGTH 0! ;

--- Source Stack ---

create BUFFER-STACK  32768 allot ( The input buffer stack )
variable @BFR-STACK  BUFFER-STACK @BFR-STACK !

: ?source ( -- ? )  @BFR-STACK @ BUFFER-STACK u> ;    ( check if there are files on the stack )
: >source ( -- )    ( push the current source file on the input buffer stack )
  @BUFFER @ CURSOR @ LENGTH @ FILEID @ @FILENAME @ @NEXTCHAR @ @BFR-STACK @ !++ !++ !++ !++ !++ !++ @BFR-STACK !
  @BUFFER 0!  CURSOR 0!  LENGTH 0!  FILEID 0!  @FILENAME 0!  @FILENEXTCHAR @ @NEXTCHAR ! ;
: source> ( -- )  closeFile  ?source if    ( pop last source file from the buffer stack )
  @BFR-STACK @ --@ --@ --@ --@ --@ --@ @BFR-STACK ! @NEXTCHAR ! @FILENAME ! FILEID ! LENGTH ! CURSOR ! @BUFFER ! then ;

--- Input ---

: source ( a$ -- )  cr ." Sourcing file " dup qtype$
  FILEID @ if  >source  then  openFile  @FILENEXTCHAR @ @NEXTCHAR ! ;  ( read from the specified source file )
:noname  source ; is  sourceModule
: unsource ( -- )  source> ;  ( close current source and drop from source stack if approriate )
: exhausted ( -- ? )  CURSOR @ LENGTH @ = ;  ( check if input buffer is empty )
:noname  begin  ?source while  unsource  repeat  LENGTH @ CURSOR ! ; is closeAll

: ?BUFFER ( -- a )  @BUFFER @ ?dup unlessever  PAGESIZE allocate throw dup @BUFFER !  then ;
: readLine ( -- )    ( read a line from the console into the buffer )
  ?BUFFER  cr ." > " PAGESIZE accept  LENGTH !  10 @BUFFER @ LENGTH @ + c!  LENGTH 1+!  CURSOR 0! ;
: floodInputBuffer0 ( -- )    ( flood input buffer with next page from current file )
  FILEID @ stdin = if  readline exit  then
  ?BUFFER  PAGESIZE FILEID @ read-file throw LENGTH !  CURSOR 0! ;
: ?floodInputBuffer ( -- )  exhausted ifever  floodInputBuffer0  then ;    ( flood buffer if exhausted )
: floodInputBuffer ( -- )    ( flood input buffer, across file boundaries if necessary )
  ?floodInputBuffer  begin  exhausted ?source and while  source>  ?floodInputBuffer  repeat ;
: nextFileChar ( -- c|0 )  exhausted ifever  floodInputBuffer  then  ( return next character from file input source, or 0 )
  CURSOR dup @ dup LENGTH @ u< unless  2drop 0  else  @BUFFER @ + c@ swap 1+!  then ;
: nextConsChar ( -- c|0 )  exhausted ifever  readLine  then
  CURSOR dup @ dup LENGTH @ u< unless  2drop 0  else  @BUFFER @ + c@ swap 1+!  then ;
: nextChar ( -- c|0 )  @NEXTCHAR @ execute ;
: blank? ( c -- t | f )  $01 $21 within ;    ( check if next character is blank )
: pushback ( -- )  CURSOR 1-! ;    ( push last character back on input stream )
: $+>IN ( $ -- )  count tuck ?BUFFER LENGTH @ + swap cmove  LENGTH +! ;    ( append $ to input buffer )

: >console ( -- )    ( source from the console )
  FILEID @ if  >source  then  stdin FILEID !  c" Console" @FILENAME !  CURSOR 0!  LENGTH 0!  @BUFFER 0!
  @CONSNEXTCHAR @ @NEXTCHAR ! ;



--- Initialize ---

' nextFileChar @FILENEXTCHAR !
' nextConsChar @CONSNEXTCHAR !
>console

=== Parser ===

--- Parser State ---

10 constant Radix                   ( Default radix )
variable Tlen                       ( Token length )
variable Taddr                      ( Token address )
variable Tsign                      ( Token sign = mantissa sign )
variable Tradix                     ( Token radix )
variable Tdigits                    ( Number of digits in IntValue )
variable Tfail                      ( Token failure )
variable IntValue                   ( Integer value or mantissa of float )
variable IntValue#                  ( Number of digits in mantissa or int value )
variable CondValue                  ( Condition )
variable Mant                       ( Mantissa of float )
variable Frac                       ( Fraction of float )
variable Fraction#                  ( Number of digits in fraction )
variable ExpSgn                     ( Sign of exponent )
variable Expo                       ( Exponent of float )
variable Expo?                      ( has an "E" been spotted? )
variable Period?                    ( has an "." been spotted? )
create buffer  4096 allot           ( Buffer for 16 string literals )
variable #T$                        ( Current string number )
variable @T$                        ( String literal )

--- Parser Methods ---

: nextT$ ( -- )  #T$ dup @ dup 1 + 10 mod rot ! 256 * buffer + @T$ ! ;
: setupTP ( a # -- a # |>> a 0 f )    ( Setup the token parser )
  2dup Tlen ! Taddr !  Tsign 0!  Radix TRadix !  IntValue 0!  Tfail 0!    ( setup crucial constants )
  dup unless  false 2exit  then ;                                         ( BLACK MAGIC: exit caller if token length is 0 )
: finishTP ( a # -- a' #' f | t )  nip  Tfail @ or if  Taddr @ Tlen @ false  else  true  then ;    ( Finish token parsing )
: eat. ( a # -- a' #' )  Period? off  dup if  over c@ '.' = if  Period? on  +>  then  then ;
: eatE ( a # -- a' #' )  Expo? off  dup if  over c@ dup 'e' = swap 'E' = or if  Expo? on  +>  then  then ;
: eatSign ( a # -- a' #' sgn )  dup if  over c@ case
    '+' of  +>  0  endof
    '-' of  +> -1  endof
    $2212 ( real minus − ) of  +> -1  endof
    0 swap  endcase  else  0  then ;
: eatQuote1 ( a # -- a' #' |>> a # f )
  2dup if  c@ $27 - if  false 2exit  then  +>  dup ( stb )  then drop ;  ( BLACK MAGIC: exit caller if not a quote )
: eatQuote2 ( a # -- a' #' )  Tfail on  2dup if  c@ $27 = if  Tfail off +>  then  dup ( stb ) then  drop ;
: eatDquote1 ( a # -- a' #' |>> a # f )
  2dup if  c@ '"' - if  false 2exit  then  +>  dup ( stb )  then drop ;  ( BLACK MAGIC: exit caller if not a double quote )
: eatDquote2 ( a # -- a' #' )  Tfail on  2dup if  c@ '"' = if  Tfail off +>  then  dup ( stb )  then  drop ;
: eatUC ( a # -- a' #' uc )  Tfail on  uc@>  dup 1+ if  Tfail off  then ;
: eatEsc ( a # -- a' #' c )  +>  2dup if c@ case
    '0' of   0  endof
    'a' of   7  endof
    'b' of   8  endof
    'e' of  27  endof
    'f' of  12  endof
    'n' of  10  endof
    'r' of  13  endof
    't' of   9  endof
    dup endcase  else  drop 0 then ;
: eatRadix1 ( a # -- a' #' )  2dup if  c@ case
    '#' of  10 Tradix !  +>  endof
    '$' of  16 Tradix !  +>  endof
    '&' of   8 Tradix !  +>  endof
    '%' of   2 Tradix !  +>  endof
    endcase  else  drop  then ;
: eatRadix2 ( a # -- a' #' )  2dup if  over + 1- c@ case
    'D' of  10 Tradix !  endof
    'd' of  10 Tradix !  endof
    'H' of  16 Tradix !  endof
    'h' of  16 Tradix !  endof
    'O' of   8 Tradix !  endof
    'o' of   8 Tradix !  endof
    'B' of   2 Tradix !  endof
    'b' of   2 Tradix !  endof
    swap 1+ swap  endcase  1-  else  drop  then ;
create DIGITS  ," 0123456789ABCDEFabcdef"
: >digit ( c -- u|-1 )  DIGITS count rot cfind dup 16 > if  6 -  then  1- ;
: eatDigits ( a # -- a' #' )  Tfail on  IntValue 0!  IntValue# 0!
  begin  2dup  while
    c@ >digit dup 0 Tradix @ within unless  drop exit  then
    Tfail off  IntValue# 1+!  IntValue @ Tradix @ * + IntValue !  +>  repeat  drop ;
: eatDigits? ( a # -- a' #' )  IntValue 0!  IntValue# 0!
  begin  2dup  while
    c@ >digit dup 0 Tradix @ within unless  drop exit  then
    IntValue# 1+!  IntValue @ Tradix @ * + IntValue !  +>  repeat  drop ;
: eatChar ( a # -- a' #' )  eatUC dup '\' = if  drop eatEsc  then  IntValue ! ;
: eatChars ( a # -- a' #' )  Tfail @ unless  @T$ @ c0!  ( read characters until closing double-quote )
  begin  2dup  while  c@ $22 = if  exit  then  eatChar  IntValue @  @T$ @ count + c!  @T$ @ c1+!  repeat  drop  then ;
: mantSign ( a # -- a' #' )  Tfail @ unless  eatSign Tsign !  then ;
: mantissa ( a # -- a' #' )  Tfail @ unless  eatDigits  IntValue @ Mant !  then ;
: fraction ( a # -- a' #' )  Tfail @ unless  eatDigits?  IntValue @ Frac !  IntValue# @ Fraction# !  then ;
: expSign ( a # -- a' #' )  Tfail @ unless  eatSign ExpSgn !  then ;
: exponent ( a # -- a' #' )  Tfail @ unless  eatDigits  IntValue @ Expo !  then ;
: >f ( u -- F: -- r )  s>d d>f ;
: makeFraction ( -- F: -- r )  Frac @ >f  10 >f  Fraction# @ >f  f**  f/ ;
: makeMantissa ( -- F: -- r )  Mant @ >f  makeFraction f+  TSign @ if  fnegate  then ;
: makeExponent ( -- F: -- r )  10 >f  Expo @ >f  ExpSgn @ if  fnegate  then  f** ;
: makeFloat ( -- F: -- r )  makeMantissa makeExponent f* ;
: >int ( a # -- n|u t | a # f )                       ( Parse integer number )
  setupTP  eatSign Tsign !  eatRadix2  eatRadix1  eatDigits  finishTP  dup if  IntValue @ Tsign @ if  negate  then  swap  then ;
: >float ( a # -- r t | a # f )                       ( Parse a floating point number )
  setupTP  mantSign  mantissa  eat.  fraction  eatE  Expo? @ if  expSign  exponent  then
  Period? @ Expo? @ or unless  Tfail on  then  finishTP  dup if  makeFloat  then ;
: >char ( a # -- c t | a # f )                        ( Parse a character literal )
  setupTP  eatQuote1  eatChar  eatQuote2  finishTP  dup if  IntValue @ swap  then ;
: >string ( a # -- a$ t | a # f )  dup 255 u> if  cr ." String literal too long!" terminate  then    ( Parse a string literal )
  setupTP  nextT$  eatDquote1  eatChars  eatDquote2  finishTP  dup if  @T$ @ swap  then ;

--- Clauses ---

variable @CLAUSES

create CLAUSE-BUILDER  256 allot
: findClause ( a # -- a' #' f | xt t )  Tfail @ if  2drop Taddr @ Tlen @ false exit  then
  dup 1+ CLAUSE-BUILDER c!++ '#' !c++ swap cmove
  CLAUSE-BUILDER count @CLAUSES @ search-wordlist dup unless  Taddr @ Tlen @ rot  then ;
: findClause$ ( a # -- a' #' f | xt t )  Tfail @ if  2drop Taddr @ Tlen @ false exit  then
  dup 1+ CLAUSE-BUILDER c!++ '$' !c++ swap cmove
  CLAUSE-BUILDER count @CLAUSES @ search-wordlist dup unless  Taddr @ Tlen @ rot  then ;

: >intClause ( a # -- n|u xt t | a # f )  setupTP  eatSign Tsign !  eatRadix2  eatRadix1  eatDigits
  findClause  dup if  IntValue @ Tsign @ if  negate then  -rot  then ;
: >charClause ( a # -- n|u xt t | a # f )  setupTP  eatQuote1  eatChar  eatQuote2
  findClause  dup if  IntValue @ Tsign @ if  negate then  -rot  then ;
: >cellClause ( a # -- n|u xt t | a # f )  setupTP  Tfail on  over 4 s" cell" compare
  unless  Tfail off  swap 4 + swap 4 -  then  findClause  dup if  cell  -rot  then ;
: >stringClause ( a # -- a$ xt t | a # f )  dup 255 u> if  cr ." String literal too long!" terminate  then
  setupTP  nextT$ eatDquote1 eatChars eatDquote2 findClause$  dup if  @T$ @ -rot  then ;



=== Interpreter ===

variable @FORCEMBLER-WORDS
also Forcembler  context @ @FORCEMBLER !  previous

variable @INTERPRETER                                 ( Address of the interpreter vocabulary )
variable FORC                                         ( if we are in Forcembler mode, e.g. through CODE: )

: interpret ( a$ -- )  cr ." Interpreting " dup qtype$
  count
  2dup @INTERPRETER @ search-wordlist if  -rot 2drop execute  exit  then
  FORC @ if
    2dup @FORCEMBLER @ search-wordlist if  -rot 2drop execute  exit  then
    2dup @FORCEMBLER-WORDS @ search-wordlist if -rot 2drop execute  exit  then
    then
  2dup find-name ?dup if  -rot 2drop name>int execute  exit  then
  >int if  exit  then
  >float if  exit  then
  >char if  exit  then
  >string if  exit  then
  >intClause if  execute exit  then
  >charClause if  execute exit  then
  >cellClause if  execute exit  then
  >stringClause if  execute exit  then
  over 1- findVocabulary ?dup if  cr ." Vocabulary " dup vocabulary. §VOCA 0 >&  exit  then  drop
  cr ." Word «" type ." » not found! ⇒ quitting to FORTH." quit ;

: unvoc ( @voc -- )                                   ( Remove gforth vocabulary @voc from the search list )
  >x get-order dup 1 ?do  i pick x@ = if  i roll drop 1-  set-order  x> drop unloop exit  then  loop  x> drop ;



=== Compiler Clause Vocabularies ===

: pushHere ( -- ra )  tseg→| >CTRL ;
: resolveForward ( ctrl:ba -- )  tseg→| CTRL> tuck − swap 4- d! ;
: finishDef ( -- )
  LAST_COMP @ ?dup if  flags %LINK and if  %LINK currentWord@ flags+!  then  drop  then
  CTRLDEPTH if  unbalanced-definition  then ;
: smashCondition ( -- cc )                            ( remove condition buildup from the code segment, to replace with ?JMP )
  §CODE >seg >hend 8 - c@ $F and $4000000 ( ← Forcembler Condition Code ) or
  9 §CODE >seg hused−! ;

--- Holding ---

variable IntValue
variable CharValue
variable @StringValue
create FloatValue  10 allot

variable Held
variable Held2
1 constant IntHeld
2 constant FloatHeld
3 constant CharHeld
4 constant StringHeld
5 constant ConditionHeld

: holdInt ( n -- )  IntValue !  IntHeld Held ! ;
: holdFloat ( -- F: r -- )  FloatValue f!  FloatHeld Held ! ;
: holdChar ( uc -- )  CharValue !  CharHeld Held ! ;
: holdString ( $ -- )  @StringValue !  StringHeld Held ! ;
: holdCondition ( -- )  ConditionHeld Held ! ;
: holdCondExpr ( -- )  ConditionHeld Held2 ! ;

--- Clause Vocabulary ---

vocabulary Clauses
also Clauses definitions  context @ @CLAUSES !

--- Int Clauses ---
: #+ ( x -- )  #PLUS, ;
: #- ( x -- )  #MINUS, ;
: #− ( x -- )  #MINUS, ;
: #u× ( u -- )  #UTIMES, ;
: #u* ( u -- )  #UTIMES, ;
: #× ( u -- )  #TIMES, ;
: #* ( u -- )  #TIMES, ;
: #! ( x -- )  #STORE, ;
: #+> ( u -- )  #ADV, ;
: #pick ( u -- )  #PICK, ;
: #drop ( u -- )  #DROP, ;

: #= ( x -- )  #ISEQUAL,  holdCondExpr ;
: #< ( x -- )  #ISLESS,  holdCondExpr ;
: #> ( x -- )  #ISGREATER,  holdCondExpr ;

--- Char Clauses ---

--- Float Clauses ---

--- String Clauses ---

--- Condition Clauses ---
: ?if ( -- ctrl:ba )  smashCondition ?IF, ;
: ?ifever ( -- ctrl:ba )  smashCondition ?IFEVER, ;
: ?unless ( -- ctrl:ba )  smashCondition ?UNLESS, ;
: ?unlessever ( -- ctrl:ba )  smashCondition ?UNLESSEVER, ;
: ?until ( ctrl:ba -- )  smashCondition ?UNTIL, ;
: ?while ( ctrl:ba1 -- ctrl:ba2 ctrl:ba1 )  smashCondition ?WHILE, ;

previous definitions



=== Compiler ===

--- Punching ---

: int, ( n -- )  code-model@ case
    INDIRECT-THREADED of  int-indirect,  endof
    DIRECT-THREADED of  int-direct,  endof
    TOKEN-THREADED of  int-token,  endof
    INLINED of  int-inline,  endof
    unknown-code-model  endcase ;

: float, ( -- F: r -- )  §TEXT →tseg#↑  &tseg→| tf, tseg#↓  code-model@ case
    INDIRECT-THREADED of  float-indirect,  endof
    DIRECT-THREADED of  float-direct,  endof
    TOKEN-THREADED of  float-token,  endof
    INLINED of  float-inline,  endof
    unknown-code-model  endcase ;

: char, ( uc -- )  code-model@ case
    INDIRECT-THREADED of  int-indirect,  endof
    DIRECT-THREADED of  int-direct,  endof
    TOKEN-THREADED of  int-token,  endof
    INLINED of  int-inline,  endof
    unknown-code-model  endcase ;

: string, ( a$ -- )  §TEXT →tseg#↑  &tseg→| swap t$, tseg#↓  code-model@ case
    INDIRECT-THREADED of  string-indirect,  endof
    DIRECT-THREADED of  string-direct,  endof
    TOKEN-THREADED of  string-token,  endof
    INLINED of  string-inline,  endof
    unknown-code-model  endcase ;
:noname ( a$ -- )  string, ; is str,

: vocabulary, ( @voc --)  code-model@ case
    INDIRECT-THREADED of  voc-indirect,  endof
    DIRECT-THREADED of  voc-direct,  endof
    TOKEN-THREADED of  voc-token,  endof
    INLINED of  voc-inline,  endof
    unknown-code-model  endcase ;

: punchWord ( @voc @word -- )  code-model@ case
    INDIRECT-THREADED of  word-indirect,  endof
    DIRECT-THREADED of  word-direct,  endof
    TOKEN-THREADED of  word-token,  endof
    INLINED of  word-inline,  endof
    unknown-code-model  endcase ;

: insertJmp ( cc -- )  §CODE →tseg#↑  9 >tseg hused−!  quit ;

: ?punchLiteral ( -- )  Held @0! case
      IntHeld of  IntValue @ int,  endof
      FloatHeld of  FloatValue f@ float,  endof
      CharHeld of  CharValue @ char,  endof
      StringHeld of  @StringValue @ string,  endof
      ConditionHeld of  endof
      dup if  cr ." Invalid holding type: " dup . terminate  then  endcase ;

--- Loose Clauses ---

: ?buildClause ( $ -- $ f | t )  >x Held @ case
    0 of  x> false exit  endof
    IntHeld of  IntValue @ '#'  endof
    FloatHeld of  FloatValue f@ '%'  endof
    CharHeld of  CharValue @ '*'  endof
    StringHeld of  @StringValue @ '$'  endof
    ConditionHeld of  '?'  endof
    x> false  endcase
  dup if
    x@ c@ 1+ CLAUSE-BUILDER c!++ c!++ x@ count slide cmove
    CLAUSE-BUILDER  cr ." ---> Searching for clause " dup qtype$  count @CLAUSES @ search-wordlist dup if  ." : found."
      drop  [ also Forcembler ] depth 2- 0 max dup >B ADP+ execute B> ADP- [ previous ]  true  Held2 @0! Held !  x> drop exit  else
      ." : not found."  Held @ case
        IntHeld of  swap drop  endof
        FloatHeld of  fdrop  endof
        CharHeld of  swap drop  endof
        StringHeld of  swap drop  endof
      endcase  then
    x> swap  then ;

--- Validation ---

: !A0 ( -- )  A? if  cr ." Unbalanced blocks!" abort  then ;    ( Check that no unbalanced blocks exist )

--- Enter and Exit Definitions ---

: « ( -- )  [ also Forcembler ] ;                     ( enter macro forcembler )
: » ( -- )  [ previous ] ;                            ( exit macro forcembler )

variable @codeAddr                                    ( Start address of current code )

: insertEnter ( -- )  « ENTER, » ;
: insertExit ( -- )  « EXIT, » ;

: enterMethod ( -- )                                  ( start definition )
  §CODE →tseg#↑  1024 !tfree  2 talign,  0 tw,  tseg→| @codeAddr !  insertEnter  tseg#↓  mayLink on ;
: exitMethod ( -- )                                   ( close definition )
  resolveExxits  §CODE →tseg#↑  insertExit                ( punch EXIT into code )
  relocs dup @ swap 0! if  %RELOCS @lastWord @ flags+!  then    ( set relocations flag if relocations, and clear them )
  tvoc@ vocmodel case
    COMPACT-VOC of
      tseg→| @codeAddr @ tuck - swap 2 − w!               ( update code length )
      2 talign,  tseg→| 2 + @lastWord @ - tw,  endof      ( punch the word length )
    STRUCTURED-VOC of
      endof
    unknown-vocabulary-model  endcase
  tseg#↓ ;

--- Code for Classes ---

: pfa@ ( -- )  tvoc@ currentWord@ &PFA  « PUSHPFA, » ;
: pseg→|& ( -- )  §DATA &seg→|  « PUSHPFA, » ;

create METHODNAME  256 allot
variable DYNAMIC#
variable constDepth
also Forcembler
: lvl>0  depth dup constDepth +! ADP+ ;
: lvl>1  depth 1- dup constDepth +! ADP+ ;
: lvl>2  depth 2- dup constDepth +! ADP+ ;
: lvl>   constDepth @ ADP-  0 constDepth ! ;
: lvl++  -1 dup constDepth +! ADP+ ;
: lvl2+  -2 dup constDepth +! ADP+ ;
: lvl?   ." ADP=" ADP? . ;
previous

: createDynamic ( addr$ -- )                          ( create adress in instance data space )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or!  createWord  cr ." > base val"
  §CODE →tseg#↑  lvl>0  enterMethod  tvoc@ c" Size" !para@ 1+ @ « #PLUS, »
  exitMethod  lvl>  -1 wordComplete !  tseg#↓  lvl> ;
: createDynamicVal ( # &tp|0 val$ -- )                ( create dynamic value val$ of size # and type &tp )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! dup >x  createWord  dup #PFA,  ( create basic val )  cr ." > base val"
  §CODE →tseg#↑  lvl>0  enterMethod  tvoc@ c" Size" !para@ 1+ dup >x @ dup DYNAMIC# ! « #PLUS, »  over abs x> +!
  exitMethod  -1 wordComplete !  tseg#↓  lvl>
  METHODNAME x> $>$ '@' c+>$  createWord  #PFA,         ( create getter )  cr ." > getter"
  §CODE →tseg#↑  lvl>0  enterMethod  DYNAMIC# @ swap lvl++ « ##FETCH, »  exitMethod  -1 wordComplete !  tseg#↓  lvl> ;
: createDynamicVar ( # &tp|0 var$ -- )                ( create dynamic variable var$ of size # and type &tp )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! dup >x  createWord  dup #PFA,  ( create basic var )  cr ." > base var"
  §CODE →tseg#↑  lvl>0  enterMethod  tvoc@ c" Size" !para@ 1+ dup >x @ dup DYNAMIC# ! « #PLUS, »  over abs x> +!
  exitMethod  -1 wordComplete !  tseg#↓  lvl>
  METHODNAME x@ $>$ '@' c+>$  createWord  dup #PFA,     ( create getter )  cr ." > getter"
  §CODE →tseg#↑  lvl>0  enterMethod  DYNAMIC# @ 2 pick « ##FETCH, »  exitMethod  -1 wordComplete !  tseg#↓  lvl>
  METHODNAME x> $>$ '!' c+>$  createWord  #PFA,         ( create setter )  cr ." > setter"
  §CODE →tseg#↑  lvl>0  enterMethod  DYNAMIC# @ swap lvl++ « ##STORE, »  exitMethod  -1 wordComplete !  tseg#↓  lvl> ;
: allotDynamic ( # -- )  cr ." Dynamic allot " dup .  tvoc@ c" Size" !para@ 1+ +! ; ( allot # bytes of any value in instance data space )
: 0allotDynamic ( # -- )  cr ." Dynamic 0allot " dup .  tvoc@ c" Size" !para@ 1+ +! ; ( allot # bytes of value 0 in instance data space )
: createStatic ( addr$ -- )                           ( create adress in instance data space )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or!  createWord  PFA,  cr ." > base val"
  §CODE →tseg#↑  lvl>0  enterMethod  pfa@  exitMethod  lvl>  -1 wordComplete !  tseg#↓  lvl> ;
: createStaticVal ( x # &tp|0 val$ -- )  >x           ( create static value val$ with value x, size # and type &tp )
  METHODNAME x@ $>$ '@' c+>$  createWord  PFA,          ( create getter )  cr ." > getter"
  §CODE →tseg#↑  lvl>0  enterMethod  0 swap lvl>1 pseg→|& « ##FETCH, »  exitMethod  -1 wordComplete !  tseg#↓  lvl>
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! x>  createWord  §CODE →tseg#↑  ( create base val )  cr ." > base val"
  drop  lvl>1  PFA,  #pf,  enterMethod  pfa@  exitMethod  lvl>  -1 wordComplete !  tseg#↓ ;
: createStaticVar ( # &tp|0 var$ -- )  >x  drop       ( create static variable val$ with size # and type &tp )
  METHODNAME x@ $>$ '@' c+>$  createWord  PFA,          ( create getter )  cr ." > getter"
  §CODE →tseg#↑  lvl>0  enterMethod  0 over lvl>1 pseg→|& lvl2+ « ##FETCH, »  exitMethod  -1 wordComplete !  tseg#↓  lvl>
  METHODNAME x@ $>$ '!' c+>$  createWord  PFA,          ( create setter )  cr ." > setter"
  §CODE →tseg#↑  lvl>0  enterMethod  0 over lvl>1 pseg→|& lvl2+ « ##STORE, »  exitMethod  -1 wordComplete !  tseg#↓  lvl>
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! x>  createWord  §CODE →tseg#↑  ( create base val )  cr ." > base val"
  lvl>1  PFA,  0 swap #pf,  enterMethod  pfa@  exitMethod  lvl>  -1 wordComplete !  tseg#↓ ;
: createStaticObject ( &tp obj$ -- )                  ( create direct static object obj$ of type &tp )
  over &>a c" Size" !para@ 1+ @ >x                      ( = size of object instance )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or!  createWord  PFA,  §CODE →tseg#↑  ( create base val )  cr ." > base val"
  §DATA →tseg#↑  dup t&,  tseg#↓  lvl>1  enterMethod  pfa@  exitMethod  lvl>  -1 wordComplete !  tseg#↓
  §DATA →tseg#↑  x> tallot, tseg#↓ ;
: allotStatic ( # -- )                                ( allot # bytes of any value in vocabulary data space )
  cr ." Static allot " dup .  §DATA >seg hallot 2drop ;
: 0allotStatic ( # -- )                               ( allot # bytes of value 0 in vocabulary data space )
  cr ." Static 0allot " dup .  §DATA >seg 0hallot 2drop ;

--- Main ---

: compile ( $ -- )  cr ." Compiling " dup qtype$
  ?buildClause if  exit  then
  ?punchLiteral
  findWord if  flags %CONDITION and if  holdCondition  then  cr ." punchword" .sh punchWord  exit  then
  count
  >int if  holdInt exit  then
  >float if  holdFloat exit  then
  >char if  holdChar exit  then
  >string if  holdString exit  then
  >intClause if  execute exit  then
  >charClause if  execute exit  then
  >cellClause if  execute exit  then
  >stringClause if  execute exit  then
  2dup @COMP-WORDS @ search-wordlist if
    -rot 2drop [ also Forcembler ] depth 1- 0 max dup >B ADP+ execute B> ADP- [ previous ] exit  then
  over 1- findVocabulary  if  vocabulary, exit  then  drop
  word-not-found ;
:noname ( $ -- )  compile ; is compile,



=== REPL ===

--- Eval: to interpret, compile, or what? ---

variable EVALUATOR   ' interpret EVALUATOR !
: doInterpret ( -- )  ['] interpret EVALUATOR ! ;
: doCompile ( -- )  ['] compile EVALUATOR ! §CODE tseg#! ;

--- Read ---

create BUFFER  256 allot    ( input buffer for words from various sources )

: buffer0! ( -- a )  0 BUFFER c!++ ;    ( Initialize input buffer and return address where to write next char )
: quoted? ( -- ? )  BUFFER dup c@ 0- swap 1+ c@ $22 = and ;
: >>bl ( -- )  begin  nextChar  blank? 0= until  pushback ;    ( Skip blanks in input stream )
: delimiter?  ( c -- ? )  quoted? if  $22 =  else  blank?  then ;
: readWord ( -- a$ )  >>bl  buffer0!    ( Read blank-delimited token or empty )
  begin  nextChar dup delimiter? 0= while  !c++  BUFFER c1+!  repeat
  drop  quoted? if  $22 !c++  BUFFER c1+!  then
  drop  BUFFER ;
: readName ( -- a$ )  readWord dup c@ unless  cr ." End of input: definition terminateed!" exit  then ;
: readString ( c -- a$ )  buffer0!  >>bl    ( Read c-delimited token or empty )
  begin  nextChar  rot 2dup ≠ while  rev c!++  BUFFER c1+!  repeat
  2drop drop  BUFFER ;
: comment-bracket ( a$ -- )  begin  readWord  2dup c@ 0-  -rot $$= and until  drop ;    ( Skip tokens until one matches a$ )
: notEmpty? ( a$ -- a$ ? )  dup c@ 0- ;

--- Loop ---

: REPL ( -- )  begin  readWord notEmpty? while  EVALUATOR @ execute  repeat  drop ;



=== Vocabulary Words ===

variable VOC-WORDS

vocabulary VocabularyWords
also VocabularyWords definitions  context @ VOC-WORDS !

: vocabulary; ( -- )  VOC-WORDS @ unvoc  shipVocabulary  target↓ ;    ( end vocabulary definition: ship vocabulary )
: extends ( >name -- )                                                ( load entire vocabulary into current vocabulary )
  readName findVocabulary ?dup unless  vocabulary-not-found  then
  dup voctype@ ?dup if  0 invalid-vocabulary-type  then  dup vocmodel case
    COMPACT-VOC of  insert-compact-voc  endof
    STRUCTURED-VOC of  insert-structured-voc  endof
    unknown-vocabulary-model  endcase ;
: val ( &type|# >name -- )                            ( create an unmodifiable field member of type &type or size # )
  dup 2 cells ≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." val " dup qtype$  createStaticVal ;
: var ( &type|# >name -- )                            ( create a modifiable field member of type &type or size # )
  dup 2 cells ≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." var " dup qtype$  createStaticVar ;
: object ( &type >name -- )                           ( insert a direct object of type &type )
  readName  cr ." object " dup qtype$  createStaticObject ;
: create ( >name -- )  readName  createStatic ;       ( create a name referring to the parameter segment )
: allot ( # -- )  allotStatic ;                       ( reserve # bytes of any value in the parameter segment )
: 0allot ( # -- )  0allotStatic ;                     ( reserve # bytes of value 0 in the parameter segment )

previous definitions



=== Class Vocabulary ===

variable CLASS-WORDS

vocabulary ClassWords
also ClassWords definitions  context @ CLASS-WORDS !

: class; ( -- )                                       ( end class definition: ship class )
  CLASS-WORDS @ unvoc  shipVocabulary  target↓ ;
: val ( &type|# >name -- )                            ( create an unmodifiable field member of type &type or size # )
  dup 2 cells ≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." val " dup qtype$
  nextFlags @ %STATIC and if  createStaticVal  else  createDynamicVal  then ;
: var ( &type|# >name -- )                            ( create a modifiable field member of type &type or size # )
  dup 2 cells ≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." var " dup qtype$
  nextFlags @ %STATIC and if  createStaticVar  else  createDynamicVar  then ;
: construct: ( >name -- )                             ( create a constructor )
  readName  %CONSTRUCTOR nextFlags or!  cr ." constructor " dup type$  createWord  doCompile  enterMethod ;
: destruct: ( -- )                                    ( create a destructor )
  %DESTRUCTOR nextFlags or!  cr ." destructor "  c" destroy"  createWord  doCompile  enterMethod ;
: implements ( >name -- )                             ( add a base interface )
  readName  loadModule depend ;
: create ( >name -- )                                 ( create a name referring to the parameter segment )
  readName  nextFlags @ %STATIC and if  createStatic  else  createDynamic  then ;
: allot ( # -- )                                      ( reserve # bytes of any value in the parameter segment )
  nextFlags @ %STATIC and if  allotStatic  else  allotDynamic  then ;
: 0allot ( # -- )                                     ( reserve # bytes of value 0 in the parameter segment )
  nextFlags @ %STATIC and if  0allotStatic  else  0allotDynamic  then ;

previous definitions



=== Interface Vocabulary ===

variable INTERFACE-WORDS

vocabulary InterfaceWords
also InterfaceWords definitions  context @ INTERFACE-WORDS !

: interface; ( -- )                                   ( end interface definition: ship interface )
  INTERFACE-WORDS @ unvoc  shipVocabulary  target↓ ;
: def ( >name -- )  readName createDef ;              ( add a method definition to the interface )

previous definitions



=== Enum Vocabulary ===

variable ENUM-WORDS

vocabulary EnumWords
also EnumWords definitions  context @ ENUM-WORDS !

: enum; ( -- )                                        ( end enum definition: ship enum )
  ENUM-WORDS @ unvoc  shipVocabulary  target↓ ;
: symbol ( >name -- )                                 ( add a symbol to the enum )
  tvoc@ c" Next" !para@ 1+ dup @ readName  cr ." constant " dup qtype$  createWord  §CODE →tseg#↑
  lvl>1  PFA,  pf,  enterMethod  pfa@  « FETCH, »  exitMethod  lvl>  -1 wordComplete !  tseg#↓
  1+!  tvoc@ c" Count" !para@ 1+ 1+! ;

previous definitions



=== Compiler Vocabulary ===

vocabulary compiler
also compiler definitions  context @ @COMP-WORDS !
\ needs IntClauses.gf

: exit ( -- )  « EXXIT, »  LAST_COMP0! ;
: lit0 ( -- )  « LIT0, »  LAST_COMP0! ;
: lit-1 ( -- )  « LIT-1, »  LAST_COMP0! ;
: lit1 ( b -- )  « LIT1, »  LAST_COMP0! ;
: ulit1 ( c -- )  « ULIT1, »  LAST_COMP0! ;
: lit2 ( s -- )  « LIT2, »  LAST_COMP0! ;
: ulit2 ( w -- )  « ULIT2, »  LAST_COMP0! ;
: lit4 ( i -- )  « LIT4, »  LAST_COMP0! ;
: ulit4 ( d -- )  « ULIT4, »  LAST_COMP0! ;
: lit8 ( l -- )  « LIT8, »  LAST_COMP0! ;
: ulit8 ( q -- )  « ULIT8, »  LAST_COMP0! ;
: litf ( &r -- ) « LITF, »  LAST_COMP0! ;
: lit$ ( &$ -- )  « LIT$, »  LAST_COMP0! ;
: my ( -- a )  « THIS, » ;  alias me  alias I'm  alias this   ( push the current instance )
: raise ( -- )  « EXPUSH, » ;
: begin ( -- ctrl:ba )  « BEGIN, » ;
: then ( ctrl:ba -- )  « THEN, » ;
: again ( ctrl:ba -- )  « AGAIN, » ;
: until ( ctrl:ba -- )  « UNTIL, » ;
: while ( ctrl:ba1 -- ctrl:ba2 ctrl:ba1 )  « WHILE, » ;
: repeat ( ctrl:ba2 ctrl:ba1 -- )  « REPEAT, » ;
: if ( -- ctrl:ba )  « IF, » ;
: ifever ( -- ctrl:ba )  « IFEVER, » ;
: unless ( -- ctrl:ba )  « UNLESS, » ;
: unlessever ( -- ctrl:ba )  « UNLESSEVER, » ;
: else ( ctrl:ba1 -- ctrl:ba2 )  « ELSE, » ;
: ( ( >...rpar -- )  c" )" comment-bracket ;          \ skips a parenthesis-comment
: ;  finishDef  exitMethod  -1 wordComplete !  LASTCONTRIB 0!  LAST_COMP0!  doInterpret ;     \ finish definition

previous definitions



=== Additional Forcembler Words ===

vocabulary ForcemblerWords
also ForcemblerWords  definitions  context @ @FORCEMBLER-WORDS !

: SAVE, ( -- )  « PUSH, »  %JOIN @lastWord @ flags+! ;     ( Insert DUP and mark word as joiner )
: RESTORE, ( -- )  « DROP, »  %LINK @lastWord @ flags+! ;  ( Insert DROP and mark word as linker )
: ; ( -- )  tseg#↓  exitMethod  -1 wordComplete !  FORC 0!  %INLINE @lastWord @ flags+! ;    ( Finish code word )

previous definitions



=== Interpreter Vocabulary ===

: pervious previous ;
: als0 also ;

vocabulary Interpreter
also Interpreter definitions  context @ @INTERPRETER !

1 constant U1
2 constant U2
4 constant U4
8 constant U8
-1 constant N1
-2 constant N2
-4 constant N4
-8 constant N8

: vocabulary ( >name -- )                             ( create a vocabulary with name from input stream )
  readName  cr ." vocabulary " dup qtype$  createVocabulary  §PARA →tseg#↑  c" Package" t$, currentPackage t$,  tseg#↓ ;
: package ( >name -- )                                ( adds a package specification to the vocabulary )
  currentPackage readName  cr ." package " dup qtype$ $>$ drop ;
: also ( >name -- )                                   ( push vocabulary with name from input stream onto search order )
  readName  findVocabulary ?dup if  addSearchVoc exit  then
  cr ." Vocabulary «" type$ ." » not found!" terminate ;
: definitions ( -- )  primary tvoc! ;                 ( set top vocabulary of search order to target vocabulary )
: previous ( -- )  previousOrder ;                    ( pop top vocabulary from search order )
: inline ( -- )  %INLINE @lastWord @ flags+! ;        ( make last word inline )
: join ( -- )  %JOIN @lastword @ flags+! ;            ( Mark current word as joiner )
: link ( -- )  %LINK @lastword @ flags+! ;            ( Mark current word as linker )
: private ( -- )  @lastword @ flags %VISIBILITY andn  %PRIVATE or swap w! ;  ( Mark current word as private )
: condition ( -- )  %CONDITION @lastword @ flags+! ;  ( Mark current word as a condition )
: target ( -- @voc|0 )  tvoc@ ;                       ( Current target vocabulary )
: constant ( x >name -- )                             ( create a constant with value x )
  readName  cr ." constant " dup qtype$  createWord  §CODE →tseg#↑
  lvl>1  PFA,  pf,  enterMethod  pfa@  « FETCH, »  exitMethod  lvl>  -1 wordComplete !  tseg#↓ ;
: variable ( >name -- )                               ( create a variable with initial value 0 )
  readName  cr ." variable " dup qtype$  createWord  §CODE →tseg#↑
  0 lvl>1  PFA,  pf,  enterMethod  pfa@  exitMethod  lvl>  -1 wordComplete !  tseg#↓ ;
: =variable ( x >name -- )                            ( create a variable with initial value x )
  readName  cr ." =variable " dup qtype$  createWord  §CODE →tseg#↑
  lvl>1  PFA,  pf,  enterMethod  pfa@  exitMethod  lvl>  -1 wordComplete !  tseg#↓ ;
: import ( >path -- )  readName  loadModule ;         ( import the file with the specified path or name )
: requires ( >name -- )  readName                     ( import the specified file and make it a dependency of the current voc )
  loadModule depend ;
: s" ( >string" -- a # )  '"' readString count ;      ( read a dquote-delimited string from the input stream )
: quit ( -- )  closeAll  quit ;                       ( quit the REPL )
: ****** ( >... ****** )  c" ******" comment-bracket ;    ( skip a 6*-comment )
: ------ ( >... ------ )  c" ------" comment-bracket ;    ( skip a 6-dash-comment )
: --- ( >... --- )  c" ---" comment-bracket ;         ( skip a 3-dash-comment )
: === ( >... === )  c" ===" comment-bracket ;         ( skip a 3=-comment )
: see ( >name -- )  readName  findWord if             ( print word )
  word.  else  cr ." Word «" type$ ." » not found!"  then ;
: vocabulary: ( >name -- )  vocabulary  0 >voctype    ( create vocabulary and set up for definitions )
  lastVoc @ addSearchVoc  definitions  als0 VocabularyWords  %STATIC autoFlags or! ;
: class: ( >name -- )  vocabulary  1 >voctype         ( create class and set up for its body )
  lastVoc @ addSearchVoc  definitions  als0 ClassWords  §PARA →tseg#↑  c" Size" t$, cell tc, 0 t, tseg#↓ ;
: interface: ( >name -- )  vocabulary  2 >voctype     ( create interface and set up for its body )
  lastVoc @ addSearchVoc  definitions  als0 InterfaceWords ;
: enum: ( >name -- )  vocabulary  3 >voctype          ( create enum and set up for its body )
  lastVoc @ addSearchVoc  definitions  als0 EnumWords
  §PARA →tseg#↑  c" Base" t$, cell tc, 0 t,  c" Next" t$, cell tc, 0 t,  c" Count" t$, cell tc, 0 t,  tseg#↓ ;
: code: ( >name -- )                                  ( create machine code word )
  readName  cr ." code: " dup type$  createWord  enterMethod  -1 FORC !  §CODE →tseg#↑ ;
: alias ( >name -- )                                  ( create an alias for the last word with the given name )
  readname  cr ." alias " dup qtype$  createAlias ;
: public: ( -- )  %VISIBILITY autoFlags andn!  %PUBLIC autoFlags or! ;        ( set default visibility to public )
: private: ( -- )  %VISIBILITY autoFlags andn!  %PRIVATE autoFlags or! ;      ( set default visibility to private )
: protected: ( -- )  %VISIBILITY autoFlags andn!  %PROTECTED autoFlags or! ;  ( set default visibility to protected )
: package: ( -- )  %VISIBILITY autoFlags andn!  %PACKAGE autoFlags or! ;      ( set default visibility to package )
: init: ( -- )                                        ( creates the module entry point )
  cr ." init: " c" _main_" %PRIVATE nextFlags or!  createWord  doCompile  enterMethod ;
: ( ( >...rpar -- )  c" )" comment-bracket ;          \ skips a parenthesis-comment
: : \ >name -- \                                      \ create a code word with name from input stream \
  readName  cr ." : " dup type$  createWord  doCompile  enterMethod ;

pervious definitions

REPL
