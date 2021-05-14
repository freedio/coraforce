\ FORCE Core for GForth Linux-4.19 amd64

\ Goals:
\ - Compile FORCE modules
\ - Generate binaries (vocabularies and executables)
\ - Cross-compilation



require ../000-Preconditions/ForceEmu.gf

=== Preliminary stuff ===

------
It is not safe to use methods starting with an underscore ‹_› outside of an object (→ private method)
------

4096 constant PAGESIZE
$00090000 constant version

defer closeAll
: terminate cr ." ⇒ back to FORTH..." closeAll quit ;

--- Exception Handling ---

: indirect-threading-not-supported! ( -- )  cr ." Indirect threading not yet supported!"  terminate ;
: token-threading-not-supported! ( -- )  cr ." Token-threading not yet supported!"  terminate ;
: word-not-found! ( a # -- )  cr ." Word not found: " qtype '!' emit  terminate ;
: word-not-found$! ( a$ -- )  count  word-not-found! ;
: unknown-vocabulary-model! ( u -- )  cr ." Unknown vocabulary model: " . '!' emit  terminate ;
: unknown-code-model! ( u -- )  cr ." Unknown code model: " . '!' emit  terminate ;
: vocabulary-not-found! ( $ -- )  cr ." Vocabulary «" type$  ." » not found!" terminate ;
: not-implemented! ( -- )  cr ." Method not implemented!" terminate ;
: unbalanced-definition! ( -- )  cr ." Unbalanced definition!" terminate ;
: invalid-secondary-held! ( u -- )  cr ." Invalid secondary held: type=" . '!' emit  terminate ;
: condition-unknown! ( $ -- )  cr ." Condition «" type$ ." » unknown!"  terminate ;
: has-multiple-results! ( # $ -- )  cr qtype$ ."  has " . ." results — narrow the search!"  terminate ;
: module-not-found! ( $ -- )  cr ." Module " qtype$ ."  not found!"  terminate ;
: vocabulary-has-no-name! ( -- )  cr ." Vocabulary has no name!"  abort ;
: parameter-not-found! ( $ -- )  cr ." Vocabulary parameter «" type$ ." » not found!"  terminate ;
: invalid-vocabulary-type! ( act exp -- )  cr ." Invalid vocabulary type: expected " . ." but got " .  terminate ;
: module-not-found-in-package-tree! ( $ -- )  cr ." Module " qtype$ ."  not found in package tree!" terminate ;
: no-target-vocabulary! ( -- )  cr ." No target vocabulary!" abort ;
: ambiguous-word! ( w$ -- )  cr ." Name «" type$  ." » ambiguous across vocabularies! Specify voc or use global name."  terminate ;




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
  • CAPACITY: Capacity of the heap in bytes.
  • SIZE: Amount of bytes already used.
These properties are captured in an object called HeapDescriptor.

‹@hd› stands for "address of heap descriptor"

Heaps should grow in pages (PAGESIZE bytes) and usually don't shrink (or then in pages, too).

A heap is active if it has been allocated, in other words if both ADDR and SIZE are not 0.
------

--- Heap Descriptor ---

0000  dup constant ADDR
cell+ dup constant CAPACITY
cell+ dup constant SIZE
cell+     constant Heap#

--- Heap Primitives ---

: haddr ( @hd -- @addr )  ADDR + ;                    ( Address of ADDR field )
: hcapa ( @hd -- @capa )  CAPACITY + ;                ( Address of CAPACITY field )
: hsize ( @hd -- @size )  SIZE + ;                    ( Address of SIZE field )
: haddr@ ( @hd -- a )  haddr @ ;                      ( Start address of the heap )
: hcapa@ ( @hd -- u )  hcapa @ ;                      ( Capacity of the heap )
: hsize@ ( @hd -- u )  hsize @ ;                      ( Size of the heap )
: haddr! ( a @hd -- )  haddr ! ;                      ( set start address of heap at a )
: hcapa! ( u @hd -- )  hcapa ! ;                      ( set heap capacity to u )
: hsize! ( u @hd -- )  hsize ! ;                      ( set heap size to u )
: hcapa+! ( u @hd -- )  hcapa +! ;                    ( Increase heap capacity by u )
: hsize+! ( u @hd -- )  hsize +! ;                    ( Increase heap size by u )
: hsize−! ( u @hd -- )  dup hsize@ rot min swap hsize −! ;      ( Decrease heap size by u )
: hfree@ ( @hd -- u )  dup hcapa@ swap hsize@ - ;     ( Remaining space on the heap )
: heap ( @hd -- addr size )  dup haddr@ swap hsize@ ; ( Address and size of heap )
: |heap| ( @hd -- addr capa )  dup haddr@ swap hcapa@ ;         ( Address and capacity of heap )
: -heap ( @hd -- addr+used used )  dup haddr@ swap hsize@ tuck + swap ;  ( End address and size of heap )
: >hend ( @hd -- a )  heap + ;                        ( Address of first byte after heap )
: hempty? ( @hd -- ? )  hsize@ 0= ;                   ( check if heap @hd is empty )
: hset ( u @hd -- a )  over PAGESIZE ->| tuck allocate throw    ( allocate the heap for size u and return heap address )
  dup >r over haddr!  tuck hcapa!  hsize! r> ;

--- Heap Operations ---

: newHeap ( >name -- )  create 0 , 0 , 0 , ;          ( create named heap )
: _hallocate ( @hd -- )                               ( allocate the initial heap )
  PAGESIZE dup allocate throw rot tuck haddr!  tuck hcapa!  0 swap hsize! ;
defer printVoc
: #hgrow ( @hd u -- @hd )                             ( grow segment by at least u )
  over hcapa@ + PAGESIZE ->| over haddr@ over resize throw 2 pick haddr! over hcapa! ;
: !hfree ( @hd u -- @hd )  over hfree@ over u< if  #hgrow dup  then drop ;  ( make sure at least u bytes are available on heap @hd )
: !hactive ( @hd -- @hd )  dup haddr@ unless  dup _hallocate  then ;    ( make sure the heap is active )
: hallot ( # @hd -- a # )  2dup >hend 2swap  !hactive  over !hfree  hsize+!  swap ;    ( allot # bytes on heap @hd → @allotted )
: 0hallot ( # @hd -- a # )  hallot  2dup 0 cfill ;
: h#, ( x # @hd -- )  !hactive  cell !hfree  rot over >hend ! hsize+! ;    ( append # bytes of x to heap @hd )
: h, ( x @hd -- )  cell swap h#, ;                    ( append cell x to heap @hd )
: hd, ( d @hd -- )  4 swap h#, ;                      ( append unsigned double word w to heap @hd )
: hw, ( w @hd -- )  2 swap h#, ;                      ( append unsigned word w to heap @hd )
: hc, ( c @hd -- )  1 swap h#, ;                      ( append unsigned byte c to heap @hd )
: hf, ( @hd -- F: r -- )  !hactive  10 !hfree  dup >hend f!  10 swap hsize+! ;    ( append 10byte float r to heap @hd )
: h$, ( $ @hd -- )  !hactive  over c@ 1+ tuck !hfree  dup >hend -rot  hsize+!  over c@ 1+ cmove ;    ( append $ to heap @hd )
: ha#, ( a # @hd -- )  !hactive  over !hfree  dup >hend -rot  2dup hsize+! drop cmove ;    ( append buffer a# to heap @hd )

--- Table Operations ---

------
A table is a list of heaps (called segments), as typically used in a vocabulary.
------

: createTable ( # -- a )  Heap# * dup allocate throw  dup rot 0 cfill ;    ( create table of # heaps and return its address )
: >segment ( a # -- @hd )  Heap# * + ;                ( Select the #th segment of table a )



=== Vocabulary Table ===

newHeap Vocabularies

--- Vocabulary Table Operations ---

defer printVocabularyName
: addVocabulary ( @voc -- )  Vocabularies h, ;        ( append vocabulary @voc to the vocabulary table )
: vocabularies. ( -- )  cr ." List of vocabularies:"  ( Lists the vocabulary table )
  Vocabularies heap cell/ 0 ?do  dup @ cr ." • " printVocabularyName  cell+  loop  drop ;
: @voc# ( @voc -- # )                                 ( Index # of vocabulary @voc )
  Vocabularies heap cell/ 0 ?do  2dup @ = if  2drop i unloop exit  then  cell+  loop
  drop cr printVocabularyName ."  not found!" abort ;
: #voc@ ( # -- @voc )                                 ( Lookup vocabulary @voc by index # )
  Vocabularies heap cell/ 2 pick u< if  cr ." Vocabulary number out of range: " drop . abort  then  swap cells+ @ ;



=== Vocabulary ===

------
The term ‹variables› is used here in the general sense of «mutable data», as opposed to ‹constants›.

A vocabulary is the following list of heaps:
  • DICT  the dictionary contains the word list (structured).
  • CODE  the code segment contains the executable code (structured) or everything except data (compact).
  • DATA  the R/W data segment contains variables (mutable data).
  • TEXT  the R/O text segment contains word names, constants, or just constants (compact).
  • PARA  the parameter table contains module parameters and statistics, such as name, source, package, #words etc.
  • RELS  the relocation table contains address fixups for code loading.
  • DEPS  the dependency table contains references to other vocabularies needed to execute this one.
  • DBUG  the debug segment contains debug information.
  • VMLT  the virtual method lookup table.
  • LWLT  the local word lookup table is a hash table containing word references.

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
1+ dup constant §DEPS
1+ dup constant §DBUG
1+ dup constant §VMLT
1+ dup constant §LWLT
    1+ constant segments
    15 constant §VOCA

( Segment Names [segment$] )
create DICT$ ," dictionary"
create CODE$ ," code segment"
create DATA$ ," data segment"
create TEXT$ ," text segment"
create PARA$ ," parameter table"
create RELS$ ," relocation table"
create DEPS$ ," dependency table"
create DBUG$ ," debug segment"
create VMLT$ ," virtual method lookup table"
create LWLT$ ," local word lookup table"
create SEGNAMES DICT$ , CODE$ , DATA$ , TEXT$ , PARA$ , RELS$ , DEPS$ , DBUG$ , VMLT$ , LWLT$ ,

--- Static state ---

variable lastVoc                                      ( Last created vocabulary )
variable targetVoc                                    ( Current target vocabulary )
variable targetSegment                                ( Current target segment )
variable tempSearchVoc                                ( Temporary search vocabulary )
create currentPackage  256 allot                      ( Name of last selected package )
  currentPackage 0!

--- Vocabulary Model ---

variable VOCAMODEL
0 constant COMPACT-VOC
1 constant STRUCTURED-VOC

--- Vocabulary Primitives ---

: !@segdescr ( @voc seg# -- @h )                      ( Address @h of descr of segment seg# in vocabulary @voc, asserting alloc )
  dup §VOCA - if  >segment !hactive dup  then  drop ;
: @segdescr ( @voc seg# -- @h )                       ( Address @h of descr of segment seg# in vocabulary @voc, NOT allocating )
  dup §VOCA - if  >segment dup  then  drop ;
: @segaddr ( @voc seg# -- a )  !@segdescr haddr@ ;    ( Address a of segment seg# in vocabulary @voc )
: segrange ( @voc seg# -- a u )  !@segdescr heap ;    ( Address a and length u of segment seg# in vocabulary @voc )
: segcapacity ( @voc seg# -- u )  !@segdescr hcapa@ ; ( Capacity u of segment seg# in vocabulary @voc )
: segsize ( @voc seg# -- u )  !@segdescr hsize@ ;     ( Size u of segment seg# in vocabulary @voc )
: tvoc@ ( -- @voc )  targetVoc @                      ( Current target vocabulary @voc )
  ?dup unless  no-target-vocabulary!  then ;
: tvoc! ( @voc -- )  targetVoc ! ;                    ( make @voc the new target vocabulary )
: >target ( @voc -- )  targetVoc @ >x tvoc! ;         ( push current target vocabulary and make @voc the new one )
: target> ( -- )  x> tvoc! ;                          ( pop current target vocabulary )
: @tsegdescr ( seg# -- @sd )  tvoc@ swap !@segdescr ; ( Address of descriptor of target segment seg# )
: @tsegaddr ( seg# -- a )  @tsegdescr haddr@ ;        ( Address a of target segment seg# )
: tsegcapacity ( seg# -- u )  @tsegdescr hcapa@ ;     ( Capacity u of target segment seg# )
: tsegsize ( seg# -- u )  @tsegdescr hsize@ ;         ( Size u of target segment seg# )
: !tsegfree ( u seg# -- )  @tsegdescr swap !hfree drop ;  ( make supre at least u bytes are available in target segment seg# )
: tsegrange ( seg# -- a u )  @tsegdescr heap ;        ( Address a and size u of target segment seg# )
: tseg→| ( seg# -- a )  @tsegdescr >hend ;            ( Address a of next available byte in target segment seg# )
: tseg#@ ( -- seg# )  targetSegment @ ;               ( Current target segment )
: tseg#! ( seg# -- )  targetSegment ! ;               ( set target segment to seg# )
: @tdescr ( -- @sd )  tseg#@ @tsegdescr ;             ( Address @sd of current target segment descriptor )
: @taddr ( -- a )  tseg#@ @tsegaddr ;                 ( Address a of current target segment )
: tcapacity ( -- u )  tseg#@ tsegcapacity ;           ( Capacity u of current target segment )
: tsize ( -- u )  tseg#@ tsegsize ;                   ( Size u of current target segment )
: !tfree ( u -- )  tseg#@ !tsegfree ;                 ( make sure at least u bytes are available in the current target segment )
: t→| ( -- a )  tseg#@ tseg→| ;                       ( Address of the next available byte in the current target segment )
: ↑tseg ( -- )  tseg#@ >segs ;                        ( push current target segment )
: ↓tseg ( -- )  segs> tseg#! ;                        ( pop current target segment )
: ↑tseg! ( seg# -- )  ↑tseg tseg#! ;                  ( push current target segment and set seg# as new target segment )

: tallot, ( # -- )  @tdescr hallot 2drop ;            ( allot # bytes in current target segment )
: 0tallot, ( # -- )  ?dup if  @tdescr 0hallot 2drop  then ; ( allot # bytes of 0 in current target segment )
: talign, ( # -- )                                    ( align current target segment to an even #, typically cell, 4 or 2 )
  tsize over mod dup 0= if  smash  then  - 0tallot, ;
: t, ( x -- )  @tdescr h, ;                           ( punch cell x into the current target segment )
: tc, ( c -- )  @tdescr hc, ;                         ( punch byte c into the current target segment )
: tw, ( w -- )  @tdescr hw, ;                         ( punch word w into the current target segment )
: td, ( d -- )  @tdescr hd, ;                         ( punch double-word d into the current target segment )
: tf, ( -- F: r -- )  @tdescr hf, ;                   ( punch real number r into the current target segment )
: t$, ( $ -- )  @tdescr h$, ;                         ( punch counted string $ into the current target segment )
: ta#, ( a # -- )  @tdescr ha#, ;                     ( punch buffer a with length # into the current target segment )
: t#, ( x # -- ) @tdescr h#, ;                        ( punch # lowest bytes of cell x into the current target segment )
: tseg, ( x seg# )  @tsegdescr h, ;                   ( punch cell x into segment seg# of target vocabulary )
: t#seg, ( x # seg# )  @tsegdescr h#, ;               ( punch # lowest bytes of cell x into segment seg# of target vocabulary )
: pf, ( x -- )  §DATA tseg, ;                         ( punch x into parameter field [data segment] )
: #pf, ( x # -- )  §DATA t#seg, ;                     ( punch # bytes of x into parameter field [data segment] )

: seg$ ( seg# -- )  cells SEGNAMES + @ ;              ( Name of segment seg# )
: seg$. ( seg# -- )  seg$ type$ ;                     ( print the name of segment seg# )

: para@ ( @voc n$ -- p$|0 )                           ( look up name n$ in parameter table, return value p$, or 0 if not found )
  swap §PARA segrange over +  begin  2dup - while  >r  2dup $$= if  rdrop count + nip exit  then  count + count +  r> repeat
  2drop  drop 0 ;
: !para@ ( @voc n$ -- p$ )                            ( get parameter named n$ and return its value p$, or fail )
  swap §PARA segrange over +  begin  2dup - while  >r  2dup $$= if  rdrop count + nip exit  then  count + count +  r> repeat
  2drop  parameter-not-found! ;

( Forcembler locations: )
: there  t→| ;
: toff  there ;
: backup  1 §CODE @tsegdescr hsize−! ;

--- Vocabulary Operations ---

: createVocabulary ( $ -- )                           ( create vocabulary with name $ )
  segments createTable  dup addVocabulary  dup lastVoc ! >target
  §PARA ↑tseg!  c" Name" t$, t$,  c" Model" t$,  1 tc, VOCAMODEL @ tc, ↓tseg ;
: vocabulary$ ( @voc -- voc$ )  c" Name" !para@ ;    ( Name voc$ of vocabulary @voc )
: >voctype ( t -- )  §PARA ↑tseg!  c" Type" t$, 1 tc, tc,  ↓tseg ;  ( set vocabulary type to t )
: voctype@ ( @voc -- t )  c" Type" !para@ 1+ c@ ;

create FQVOC$  256 allot
: fqvoc$ ( @voc -- fqvoc$ )  FQVOC$ $/                ( Fully qualified name voc$ of vocabulary @voc )
  over c" Package" para@ ?dup if  $>$ '/' ?c+>$  then  swap c" Name" !para@  $+>$ ;
: vocabulary. ( @voc -- )  vocabulary$ type$ ;        ( prints the vocabulary name )
: "vocabulary". ( @voc -- )  vocabulary$ qtype$ ;     ( prints the vocabulary name in double quotes )
:noname vocabulary. ; is printVocabularyName
: findVocabulary ( $ -- @voc | $ 0 )                  ( Vocabulary @voc with name $, or 0 if not found )
  Vocabularies heap cell/ 0 ?do  dup @ vocabulary$ 2 pick $$= if  nip @ unloop exit  then  cell+ loop  zap ;
: voc. ( @voc -- )
  cr ." Vocabulary " dup vocabulary$ dup type$  ."  @" over hex.
  cr ." -----------" c@ 0 udo  '-' emit  loop
  segments 0 do
    cr i seg$ 31 over c@ - 0 max 0 udo  '.' emit  loop  space type$ ." : "
    '@' emit dup haddr@ hex.  dup hsize@ hex. ." / "  dup hcapa@ hex.  Heap# + loop  drop ;
create LOCALNAME  256 allot
: >localname ( fqvoc$ -- voc$ )  count 2dup '/' cfindlast #-> dup LOCALNAME c!++ swap cmove  LOCALNAME ;
: tvoc. ( -- )
  cr ." Target Vocabulary: " tvoc@ dup vocabulary$ dup type$  swap ."  @" hex.
  cr ." -------------------" c@ 0 udo  '-' emit  loop
  segments 0 do
    cr i seg$ 31 over c@ - 0 max 0 udo  '.' emit  loop  space type$ ." : "
    '@' emit  i @tsegdescr dup haddr@ hex.  dup hsize@ hex. '/' emit  hcapa@ hex.  loop ;
:noname tvoc. ; is printVoc



=== Dependencies ===

--- Dependency table entry ---

 0000 dup constant DEPENDENCY.@NAME                   ( Address of dependency name )
cell+ dup constant DEPENDENCY.#VOCA                   ( Absolute vocabulary number )
cell+ constant DEPENDENCY#

create DEPENDENCY-NAME  256 allot
variable loadedModule

defer &there
defer target&,
: depend ( -- )  DEPENDENCY-NAME  loadedModule @ >x   ( make the current target vocabulary depend on the last loaded module )
  x@ c" Package" para@ ?dup unless cr ." Dependency " x> "vocabulary". ."  has no package name!" terminate then $>$ '/' ?c+>$
  x@ c" Name" para@ ?dup unless  cr ." Dependency " x> "vocabulary". ."  has no name property!" terminate then  $+>$
  cr ." Adding dependency " x@ "vocabulary". space ." to " tvoc@ "vocabulary". ." : " x@ @voc# .
  §TEXT ↑tseg!  &there swap t$,  ↓tseg
  §DEPS ↑tseg!  target&,  x@ @voc# t,  ↓tseg ;
: dep# ( $ @voc -- #voc t | $ f )                     ( get dependency index # of vocabulary fqpath $ in vocabulary @voc, if found )
  2dup vocabulary$ $$= if  2drop 0 true exit  then      ( $ is the own vocabulary name → index 0 )
  §DEPS segrange 1 >x begin dup while  -rot 2dup @ $$= if  2drop drop x> true exit  then  rot DEPENDENCY# #->  x> 1+ >x  repeat
  2drop x> drop false ;
: voc# ( @voc -- #voc )                               ( Dependency number of @voc in the current target vocabulary )
  tvoc@ over = if  zap exit  then                       ( @voc is the target vocabulary → index 0 )
  fqvoc$ tvoc@ dep# unless  cr ." Vocabulary " type$ ."  is not a dependency of " tvoc@ vocabulary. terminate  then ;
: @dep ( # -- @voc )  ?dup unless  tvoc@ exit  then   ( #th dependency of the target vocabulary )
  1- §DEPS tsegrange rot DEPENDENCY# u* #-> DEPENDENCY# u< if  abort" Invalid dependency index"  then
  DEPENDENCY.#VOCA + d@ #voc@ ;
: >voc# ( dep# -- voc# )  @dep @voc# ;                ( Absolute vocabulary number voc# of dep# in current target vocabulary )
: >dep# ( voc# -- dep# )  #voc@ dep# ;                ( Dependency index dep# of vocabulary index voc# )
: @vocdep ( @voc # -- @voc' )  ?dup if                ( #th dependency of vocabulary @voc )
  1- >r §DEPS segrange r> DEPENDENCY# u* #-> DEPENDENCY# u< if  abort" Invalid dependency index"  then
  DEPENDENCY.#VOCA + d@ dup . #voc@  then ;
: depfix ( @voc @dep -- @voc @dep )                   ( Insert absolute #VOCA at dep entry @dep in vocabulary @voc )
  dup DEPENDENCY.@NAME + @ >localName findVocabulary ?dup unless  cr ." Dependency " qtype$ ."  not found!" terminate then
  @voc# over DEPENDENCY.#VOCA + d! ;



=== Locators ===

------
A locator is a relocatable pointer at a location in a vocabulary, consisting of:
  • a vocabulary index
  • a segment number or type selector
  • a segment offset

A pair of locators, one source locator and one target locator, forms a relocation entry ("relocEnt").  In a relocEnt, both
vocabulary indices refer to the dependency table of the source location (0 being the source vocabulary itself).
For a single locator, the vocabulary index transiently refers to the current vocabulary table (0 being the current voc).

The locator type symbol (e.g. in stack effect comments) is ‹&›.

===> In future versions, all addresses in the system will become locators, so locators probably need to be much more versatile.
Additionally, their structure needs to change in a way that favours building addresses from locators by shift-divmod-ing its
elements top-down (i.e. the biggest unit (vocabulary#] must be in the LSB).  There will probably be a type field first that makes
it possible to distinguish several different locator types (substructures of struct Locator).
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

: >>offset ( & -- u )  %LOCATOR.OFFSET and ;          ( extract offset u from locator & )
: >>segment ( & -- seg# )  LOCATOR.SEGMENT u>> %LOCATOR.SEGMENT and ;     ( extract seg# from locator & )
: >>voc# ( & -- voc# )  LOCATOR.VOCABULARY u>> %LOCATOR.VOCABULARY and ;  ( extract vocabulary index voc# from locator & )
: >>@voc ( & -- @voc )  >>voc# #voc@ ;                                    ( extract vocabulary address @voc from locator & )
: >>extra ( & -- u )  LOCATOR.EXTRA u>> %LOCATOR.EXTRA and ;              ( extract extra info )
: <<extra ( & %u -- &' )                              ( set the extra field or locator & to %u )
  %LOCATOR.EXTRA and LOCATOR.EXTRA u<< swap %LOCATOR.EXTRA LOCATOR.EXTRA u<< andn or ;
: !seg# ( seg# -- #seg# )                             ( validate segment number )
  dup §VOCA = over 0 segments within or unless  cr ." Invalid segment index: " . abort  then ;

--- Locator Operations ---

defer reloc,
: &. ( & -- )  dup >>@voc vocabulary. '.' emit  dup >>segment seg$. '#' emit >>offset addr. ;  ( print locator & )
: >& ( @voc seg# offs -- & )  !u4                     ( create locator from @voc, seg# and offs )
(  cr ." >&: Voc=" 2 pick dup hex. "vocabulary". ." , segment=" over . ." , offset=" dup hex. )
  swap !seg#  LOCATOR.SEGMENT u<< +  swap @voc#  LOCATOR.VOCABULARY u<< + ;
: >T& ( seg# offs -- & )  tvoc@ -rot >& ;             ( create locator from target vocabulary, seg# and offs )
: &> ( & -- @voc seg# offs )  dup >>@voc over >>segment rot >>offset ;    ( explode locator into its components )
: &>a ( & -- a )  dup >>@voc  over >>segment  case    ( resolve locator & to address )
    §VOCA of  endof
    @segaddr  0 endcase
  swap >>offset + ;
: &tseg→| ( seg# -- & )  dup tsegsize >T& ;           ( create locator to end of segment seg# in target vocabulary )
: &tsegoffs ( u seg# -- & )  swap >T& ;               ( create locator for offset u in segment seg# of target vocabulary )
: &t ( -- & )  tseg#@ 0 >T& ;                         ( create locator to start of current target segment )
: &t→| ( -- & )  tseg#@ &tseg→| ;                     ( create locator to end of current target segment )
:noname tseg#@ &tseg→| ;  is &there
: &voc ( @voc -- & )  §VOCA 0 >& ;                    ( create locator to vocabulary @voc itself )
: &tvoc ( -- & )  tvoc@ &voc ;                        ( create locator to target vocabulary itself )
: &&! ( &s &t -- )  &>a swap &>a ! ;                  ( relocate s to t, full-cell source )
: c&&! ( &s &t -- )  &>a swap &>a dup 4+ rot r- swap d! ; ( relocate s to t, code-to-code, max. 32 bits )
: a& ( a @voc seg# -- & )  2dup @segaddr  3 roll r- >& ;  ( create locator for address a in segment seg# of vocabulary @voc )
: t&, ( & -- )  &t→| over &>a t,  reloc, ;            ( punch & into current target segment and create relocation entry )
:noname t&, ; is target&,
: t&! ( & a seg# -- )  tvoc@ swap a& 2dup &>a swap &>a swap ! reloc, ;  ( punch & at address a in target segment seg# )
: s&, ( & seg# -- )  ↑tseg!  t&,  ↓tseg ;             ( punch & into target segment seg# and create relocation entry )
: t& ( a seg# -- & )  tuck  @segaddr - >T& ;          ( create locator for address a in target segment seg# )
: vt& ( @voc a seg# -- & )  2 pick over @segaddr rot r− >& ;  ( create locator for address a in #seg segment of vocabulary @voc )
: withVoc ( @voc &1 -- &2 )  dup >>segment swap >>offset >& ; ( replace voc# in &1 with @voc )
: +&there ( offs -- & )  tseg#@ swap tsegsize + >T& ; ( Locator for offset offs from end of current target segment )
: >extra ( & %u -- &' )  over >>extra or <<extra ;    ( add flags %u to locator & )
: &+ ( & off -- &' )  over %LOCATOR.OFFSET and + !u4 swap %LOCATOR.OFFSET andn or ;   ( add off to offset of & )
: &>& ( & @voc -- &' )                                ( replaces voc index of & relative to @voc with an index relative to tvoc )
  dup >>voc# over >>segment rot >>offset 2swap @vocdep -rot >& ;
: abs>dep ( & -- &' )                                 ( replace vocabulary in locator & with dependency index in target vocabulary )
  &> -rot LOCATOR.SEGMENT u<< -rot voc# LOCATOR.VOCABULARY u<< + + ;



=== Relocation ===

--- Relation Table Entry Structure ---

0000  dup constant RELOC.SOURCE                       ( Source locator )
cell+ dup constant RELOC.TARGET                       ( Target locator )
cell+     constant RelocEntry#

--- Relocation State ---
variable relocs

--- Relocation Primitives ---

: _!sourceValid ( &s -- &s )  dup >>segment           ( check if source reference is valid )
  dup §DEPS = swap §CODE §TEXT within or unless  cr ." Invalid source segment: " >>segment seg$. abort  then
  dup >>@voc over >>segment segsize over >>offset u< if  cr ." Out of segment length: " >>offset . tvoc. abort  then ;
: _!targetValid ( &t -- &t )  dup >>segment           ( check if target reference is valid )
  dup §VOCA = swap §DICT §PARA within or unless  cr ." Invalid target segment: " >>segment seg$. abort  then
  dup >>@voc over >>segment segsize over >>offset u< if  cr ." Out of segment length: " dup >>offset . >>@voc voc.  abort
  then ;
: _!valid ( &t &s -- &t &s )  _!sourceValid swap _!targetValid swap ;   ( make sure both locators are valid )

--- Relocation Operations ---

:noname ( &t &s -- )                                  ( Add relocation with source &s and target &t to relocation table )
  _!valid  §RELS ↑tseg! t, t, ↓tseg ; is reloc,
: codereloc, ( &t &s -- )  %CODE-LOCATION >extra reloc, ;
: relocs. ( -- )  §RELS @tsegdescr heap RelocEntry# u/ 0 udo    ( Prints the relocation table )
  cr dup RELOC.SOURCE + @ &.  space ." -> "  dup RELOC.TARGET + @ &.  RelocEntry# +  loop  drop ;
: reloc ( @rel -- )  dup RELOC.SOURCE + @  swap RELOC.TARGET + @  over >>extra %CODE-LOCATION and if  c&&!  else  &&!  then ;
: relocate ( @voc -- )                                ( relocate vocabulary @voc )
  dup §DEPS segrange 0 udo  depfix  DEPENDENCY# + DEPENDENCY# +loop  drop
  dup §RELS segrange 0 udo  dup reloc  RelocEntry# tuck +  swap +loop  2drop ;
: relocDeps ( @voc -- )                               ( relocate dependency table of vocabulary @voc )
  dup §RELS segrange 0 udo  dup RELOC.SOURCE + @ >>segment §DEPS = if  dup reloc  then  RelocEntry# tuck +  swap +loop 2drop ;

variable DATASEG#
variable CODESEG#
: _fixreloc ( & -- &' )  dup >>segment case
    §CODE of  CODESEG# @  endof
    §DATA of  DATASEG# @  endof
    cr ." Cannot resolve relocation to " seg$. '!' emit  0 endcase
  &+ ;
: insert-voc ( @voc -- )                              ( copy the words of vocabulary @voc into the current target vocabulary )
  cr ." Copying code segment ..." §CODE segsize CODESEG# !  §CODE ↑tseg!  dup §CODE segrange ta#,  ↓tseg
  cr ." Copying data segment ..." §DATA segsize DATASEG# !  §DATA ↑tseg!  dup §DATA segrange ta#,  ↓tseg
  cr ." Adjusting relocations ..." §RELS ↑tseg!  §RELS segrange  RelocEntry# u/ 0 udo
    @++ _fixreloc t,  @++ _fixreloc t,  loop  drop  ↓tseg
  cr ." Insertion done." ;
variable COPIED
: extend ( voc$ -- )                                  ( makes the target vocabulary extend the specified vocabulary )
  cr ." Adding dependency to " loadedModule @ "vocabulary".  depend ;

create DEPENDENCIES  256 cells allot                  ( translation table for dependencies of one vocabulary )



=== Virtual Method Lookup Table ===

0000  dup constant VMTE.VOC#                          ( Absolute vocabulary number )
   4+ dup constant VMTE.#VMTE                         ( Number of entries in the following array )
   4+ dup constant VMTE.@VMTE                         ( Start of the VMTE array, each entry is a method address )
      dup constant VMTE.Header#



=== Module Shipping ===

create ModulePath  256 allot
create BaseDir$  ," /home/dio/.force/lib" \ 256 allot  s" HOME" getenv dup BaseDir$ c!  BaseDir$ 1+ swap cmove
create Headline$  19621112 d,  version d,  segments 1- d,  0 d,  32 allot  here Headline$ - constant Headline#
variable SegHeader
: moddir ( @voc -- p$ )  ModulePath dup c0!           ( Parent directory p$ of module path )
  BaseDir$ $+>$  '/' ?c+>$  over c" Package" !para@ $+>$ ;
: modpath ( @voc -- p$ )  ModulePath dup c0!          ( Module path p$ of vocabulary @voc )
  moddir  '/' ?c+>$  swap c" Name" !para@ $+>$  c" .4ce" $+>$ ;
: writeSegmentHeader ( @voc #file u -- @voc #file )   ( write segment size u )
  >x 2dup swap x> segsize SegHeader !  SegHeader cell rot write-file throw ;
: writeHeader ( @voc #file -- @voc #file )            ( write the module header for vocabulary @voc to file #file )
  over vocabulary$ count 31 min Headline$ 16 + 2dup c! 1+ swap cmove
  dup Headline$ Headline# rot write-file throw          ( write headline with magic number and version )
  segments 1- 0 do  i writeSegmentHeader  loop             ( write usage and size of each segment )
  segments 1- 1 and if  SegHeader 0!  SegHeader cell 2 pick write-file throw  then ;
: writeSegment ( @voc #file u -- @voc #file )         ( write segment u of vocabulary @voc to file #file )
  >x 2dup swap x> segrange 16 ->| rot write-file throw ;
: writeDictionary ( @voc #file -- @voc #file )  §DICT writeSegment ;
: writeCodeSegment ( @voc #file -- @voc #file )  §CODE writeSegment ;
: writeDataSegment ( @voc #file -- @voc #file )  §DATA writeSegment ;
: writeTextSegment ( @voc #file -- @voc #file )  §TEXT writeSegment ;
: writeParameterTable ( @voc #file -- @voc #file )  §PARA writeSegment ;
: writeRelocationTable ( @voc #file -- @voc #file )
  over §RELS segrange RelocEntry# u/ 0 do  ( @voc #file @rel )
    2dup RELOC.SOURCE + @ ( @voc #file @rel #file &s )  4 pick abs>dep SegHeader !  SegHeader cell rot write-file throw
    2dup RELOC.TARGET + @ ( @voc #file @rel #file &t )  4 pick abs>dep SegHeader !  SegHeader cell rot write-file throw
    RelocEntry# +  loop  drop ;
: writeDependencyTable ( @voc #file -- @voc #file )  §DEPS writeSegment ;
: writeDebugSegment ( @voc #file -- @voc #file )  §DBUG writeSegment ;
: writeVirtualMethodTable ( @voc #file -- @voc #file )
  over §VMLT segrange 0 do  ( @voc #file @vmte )
    2dup VMTE.VOC# + d@ ( @voc #file @vmte #file #voc )  >dep# SegHeader !  SegHeader 4 rot write-file throw
    2dup VMTE.#VMTE + dup d@ cells 4+ ( @voc #file @vmte #file a # )  rot write-file throw
    dup VMTE.#VMTE + d@ cells 8+ tuck + swap +loop  drop ;
: shipVoc ( @voc -- )                                 ( ship vocabulary @voc )
  cr ." Shipping vocabulary " dup "vocabulary". space
  ModulePath over c" Package" !para@ $>$  '/' ?c+>$  over c" Name" !para@ $+>$  drop
  dup moddir count 511 mkdir-parents drop               ( create the intermediate directories )
  dup modpath count w/o create-file throw               ( open a new file with path derived from vocabulary path )
  ." to " ModulePath qtype$
  writeHeader  writeDictionary  writeCodeSegment  writeDataSegment  writeTextSegment  writeParameterTable
  writeRelocationTable  writeDependencyTable  writeDebugSegment  writeVirtualMethodTable
  close-file throw  2drop ;                             ( close file )
: shipVocabulary ( -- )  targetVoc @ shipVoc ;        ( ship the current target vocabulary )



=== Search Order ===

newHeap SearchOrder

: addSearchVoc ( @voc -- )  SearchOrder h, ;          ( append vocabulary @voc to the search order => "also @voc" )
: previousOrder ( -- )  cell SearchOrder hsize−! ;    ( remove last search order entry => previous )
: removeSearchVoc ( @voc -- )                         ( remove last occurrence of vocabulary @voc from the search order )
  SearchOrder -heap cell/ 0 ?do  cell− dup @ 2 pick = if
    dup cell+ swap i move  cell SearchOrder hsize−!  drop unloop exit  then  loop
  drop cr ." Warning: vocabulary «" vocabulary. ." » not found in search list! ⇒ not removed." ;
: primary ( -- @voc|0 )                               ( Last = primary search list entry, or 0 if none )
  SearchOrder hempty? if  0  else  SearchOrder >hend  cell- @  then ;
: searchlist. ( -- )  cr ." Search order:"            ( print the search order )
  SearchOrder heap cell/ 0 ?do
    dup @  cr ." • " dup vocabulary.  dup targetVoc @ = if  space ." *"  then  ."  @" hex.  cell+  loop  drop ;



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
    #FOUND-FILES has-multiple-results!  0 endcase ;
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
defer loadDeps

create SourcePath  256 allot

create FiletimeBfr  64 allot
create FiletimeCmd  300 allot
: failed-to-decode ( a # -- )  cr FiletimeBfr qtype$ ."  is not a full ISO filedatetime @ " type  terminate ;
: digs ( a # u -- a' #' X: x -- x' )                ( reads u digits from buffer a# post-advance and add to x )
  0 udo  dup 0= if  failed-to-decode  then  over c@ '0' -  x> 10 * + >x  ->  loop ;
: skip ( a # c -- a' #' )  2 pick c@ = unless  failed-to-decode  then  -> ;    ( skip character c in buffer a# )
: getFileTime ( $ -- u )  FiletimeCmd
  c" (ls --full-time " $>$  swap $+>$  c" | awk '{ print $6 " $+>$  '"' c+>$  $20 c+>$  '"' c+>$  c" $7 }') > /tmp/% 2> /dev/null" $+>$  count system
  0 >x s" /tmp/%" slurp-file ?dup unless  drop 0 exit  then  1-  2dup FiletimeBfr -rot  a#>$ drop
  4 digs '-' skip 2 digs '-' skip 2 digs $20 skip 2 digs ':' skip  2 digs ':' skip  2 digs '.' skip  5 digs 2drop x> ;
: date. ( u -- )  s>d <# # # # # # '.' hold # # ':' hold # # ':' hold # # 'T' hold # # '-' hold # # '-' hold # # # # #> type ;

: skip/ ( $ -- a # )  count  over c@ '/' = over 0- and if  ->  then ;
variable file
: ?loadModule ( $1 $2 -- ? )                        ( try loading module $1 from root $2 and report if successful )
  ModulePath over 1+ c@ '~' = if  s" HOME" getenv a#>$ swap count -> a#+>$  else  swap $>$  then
(  cr ." ?loadModule: ModulePath 1: " ModulePath dup qtype$ space '@' emit hex. )
  SourcePath over $>$
(  cr ." ?loadModule: SourcePath 1: " SourcePath dup qtype$ space '@' emit hex. )
  '/' ?c+>$  c" src" $+>$  2 pick $+>$  c" .4th" $+>$  getFileTime
(  cr ." ?loadModule: SourcePath 2: " SourcePath qtype$ ." , source file time: " dup . )
  swap '/' ?c+>$  c" lib" $+>$  rot $+>$  c" .4ce" $+>$  getFileTime
(  cr ." ?loadModule: ModulePath 2: " ModulePath qtype$ ." , module file time: " dup . )
  ?dup unless  cr ." Module " ModulePath qtype$ ."  does not exist"  zap exit  then
  u> if  cr ." Source is newer: module " ModulePath qtype$ ."  rejected in favor of source!" false exit  then
  ModulePath cr ." Loading module "  dup qtype$  count r/o open-file ifever  ."  failed (to open)." exit  then  file !
  MODULE-HEADER 128 tuck file @ read-file throw = unlessever  ."  failed (to read header)" 0 else
    MODULE-HEADER Headline$ 16 tuck compare ifever  ."  failed: incompatible headers" 0 else
      MODULE-HEADER 16 + cr ." → vocabulary " dup qtype$  createVocabulary
      MODULE-HEADER Headline# + segments 1- 0 do           ( read segments )
        ." , "  i seg$ type$ dup @ ?dup if  ."  (" dup . ." B)"
          dup lastVoc @ i >segment hset over 16 ->| file @ read-file throw swap 16 ->| - ifever
            ."  failed (EOF)!" terminate  then  then
        cell+ loop  drop  then  then
  ." : loaded"
  lastVoc @ dup relocDeps  dup loadDeps  ." linked"  relocate  ." , relocated"
  file @ ?dup if  close-file throw  0 file !  then  lastVoc @ addSearchVoc  ." , added to searchlist." true ;
: ?loadSource ( $1 $2 -- ? )                          ( try loading module $1 from root $2 and report if successful )
  ModulePath over 1+ c@ '~' = if  s" HOME" getenv a#>$  swap count -> a#+>$  else  swap $>$  then
  '/' ?c+>$  c" src" $+>$  swap $+>$  c" .4th" $+>$  cr ." Reading source file "  dup qtype$
  dup count r/o open-file ifever  ."  failed (to open)."  drop zap exit  then  close-file throw  sourceModule true ;

--- Module Methods ---

create MODULE-NAME  256 allot
create MODULE-PATH  256 allot
create MODULE-PATH2 512 allot
variable baseClass

: loadModule ( $ -- )  MODULE-PATH swap $>$           ( load the module with name $ )
  cr ." Searching for vocabulary " dup qtype$ count '/' cxafterlast dup MODULE-NAME c!++ swap cmove  space '(' emit MODULE-NAME type$ ')' emit
  MODULE-NAME findVocabulary ?dup if  dup loadedModule !  cr ." Vocabulary " vocabulary. ."  already loaded." else
    drop lastVoc @ targetVoc @
    MODULE-PATH dup c@ 0- swap 1+ c@ '/' = and if         ( absolute module name )
      MODULE-PATH c" ~/.force" ?loadModule unless
      MODULE-PATH c" ~/.force" ?loadSource unless
      MODULE-PATH c" /usr/force" ?loadModule unless
      MODULE-PATH c" /usr/force" ?loadSource unless
      MODULE-PATH module-not-found-in-package-tree!
      then then then then  else                           ( relative module name: prefix with current package )
    currentPackage c@ if
      MODULE-PATH2 currentPackage $>$ '/' ?c+>$ MODULE-PATH $+>$ c" ~/.force" ?loadModule unless
      MODULE-PATH2 c" ~/.force" ?loadSource unless
      MODULE-PATH2 c" /usr/force" ?loadModule unless
      MODULE-PATH2 c" /usr/force" ?loadSource unless
      MODULE-PATH2 module-not-found-in-package-tree!
      then then then then  else  MODULE-PATH module-not-found-in-package-tree!  then  then
    lastVoc @ loadedModule !  targetVoc ! lastVoc !  then ;
:noname ( @voc -- )                                       ( load depdendencies of vocabulary @voc )
  dup voc.
  dup §DEPS segrange ?dup if
    0 udo dup @ loadModule  DEPENDENCY# tuck + swap +loop drop  cr ." → Vocabulary " dup "vocabulary". space dup  else
    ." , " then  2drop ;  is loadDeps



=== Vocabulary Entry (Word) Management ===

( @w is the address of a word.  For compact vocabularies: the code field; for structured: the dictionary entry.
  @word is the origin of a word, i.e. the address of the flag field.
)

--- Word Structure of Structured Vocabularies ---

0000  dup constant sFLAGS
cell+ dup constant sNFA
cell+ dup constant sCFA
cell+ constant sWORD#

--- Word Structure of Compact Vocabularies ---

( Regular:
  WORD        cFLAGS
  BYTE        cNF#
  cNF# BYTES  cNF
 *BYTES       cCFX  [alignment to next word address]
  WORD        cCF#
  cCF# BYTES  cCF
 *BYTES       cLENX [alignment to next word address]
  WORD        cLEN
)

( Alias/Indirect:
  WORD        cFLAGS
  BYTE        cNF#
  cNF# BYTES  cNF
 *BYTES       cCFAX [alignment to next cell address]
  CELL        cCFA
)

--- Word Flags ---

%0000000000000011 constant %EXECTYPE                  ( Execution type: 0 = code, 1 = direct, 2 = indirect, 3 = token )
%0000000000001100 constant %VISIBILITY                ( Visibility: 0 = private, 1 = protected, 2 = package, 3 = public )
%0000000000000000 constant %PRIVATE                   ( Visibility: private )
%0000000000000100 constant %PROTECTED                 ( Visibility: protected )
%0000000000001000 constant %PACKAGE                   ( Visibility: package private )
%0000000000001100 constant %PUBLIC                    ( Visibility: public )
%0000000000110000 constant %CODETYPE                  ( Code type: 0 = definition, 1 = method, 2 = constructor, 3 = destructor )
%0000000000000000 constant %DEFINITION                ( Code type: [colon] definition )
%0000000000010000 constant %METHOD                    ( Code type: regular method )
%0000000000100000 constant %CONSTRUCTOR               ( Code type: constructor )
%0000000000110000 constant %DESTRUCTOR                ( Code type: destructor )
%0000000001000000 constant %RELOCS                    ( Code field contains relocations )
%0000000010000000 constant %MAIN                      ( Module entry point )
%0000000100000000 constant %STATIC                    ( Static )
%0000001000000000 constant %INDIRECT                  ( There is an absolute jump address instead of the code field )
%0000001000000000 constant %ABSTRACT                  ( Abstract method: %INDIRECT + CFA=0 )
%0000010000000000 constant %CONDITION                 ( Word is a condition usable in conditional clauses )
%0000100000000000 constant %INLINE                    ( Word is inline, i.e. code copied instead of called )
%0001000000000000 constant %JOIN                      ( Word is an inline-joiner )
%0010000000000000 constant %LINK                      ( Word is an inline-linker )
%0100000000000000 constant %FALLIBLE                  ( Word can produce an exception state )
%1000000000000000 constant %PREFIX                    ( Word name is a prefix in composites )

( Linker and Joiner:
  - a joiner's first instruction is SAVE TOP − without even a [invisible] BEGIN preceding it.
  - a linker's last instruction is RESTORE TOP − without even a [invisible] THEN following it.
  - both conditions cannot be determined from the final code alone due to the mentionned strong conditions and the fact that
    PUSH TOP and SAVE TOP as well as DROP TOP and RESTORE TOP have the same appearance.
  - if a joiner follows a linker immediately, the SAVE / RESTORE pair "between them" can be dropped.
  - This condition appears quite frequently and may therefore save a lot of space and time.
)

: isFlag ( flags $ -- flags -? )
  dup c" code-threaded" $$= if  smash $10000 andn swap %EXECTYPE and 0 = exit  then
  dup c" direct-threaded" $$= if  smash $10000 andn swap %EXECTYPE and 1 = exit  then
  dup c" indirect-threaded" $$= if  smash $10000 andn swap %EXECTYPE and 2 = exit  then
  dup c" token-threaded" $$= if  smash $10000 andn swap %EXECTYPE and 3 = exit  then
  dup c" private" $$= if  smash $20000 andn swap %VISIBILITY and %PRIVATE = exit  then
  dup c" protected" $$= if  smash $20000 andn swap %VISIBILITY and %PROTECTED = exit  then
  dup c" package-private" $$= if  smash $20000 andn swap %VISIBILITY and %PACKAGE = exit  then
  dup c" public" $$= if  smash $20000 andn swap %VISIBILITY and %PUBLIC = exit  then
  dup c" definition" $$= if  smash $40000 andn swap %CODETYPE and %DEFINITION = exit  then
  dup c" method" $$= if  smash $40000 andn swap %CODETYPE and %METHOD = exit  then
  dup c" constructor" $$= if  smash $40000 andn swap %CODETYPE and %CONSTRUCTOR = exit  then
  dup c" destructor" $$= if  smash $40000 andn swap %CODETYPE and %DESTRUCTOR = exit  then
  dup c" relocs" $$= if  smash %RELOCS andn swap %RELOCS and exit  then
  dup c" main" $$= if  smash %MAIN andn swap %MAIN and exit  then
  dup c" static" $$= if  smash %STATIC andn swap %STATIC and exit  then
  dup c" indirect" $$= if  smash %INDIRECT andn swap %INDIRECT and exit  then
  dup c" abstract" $$= if  smash %ABSTRACT andn swap %ABSTRACT and exit  then
  dup c" condition" $$= if  smash %CONDITION andn swap %CONDITION and exit  then
  dup c" inline" $$= if  smash %RELOCS andn swap %RELOCS and exit  then
  dup c" joiner" $$= if  smash %JOIN andn swap %JOIN and exit  then
  dup c" linker" $$= if  smash %LINK andn swap %LINK and exit  then
  dup c" fallible" $$= if  smash %FALLIBLE andn swap %FALLIBLE and exit  then
  dup c" prefix" $$= if  smash %PREFIX andn swap %PREFIX and exit  then
  cr ." Unrecognized attribute: " dup qtype$
  false ;

variable autoFlags                                    ( Flags that get set on creating each word )
variable nextFlags                                    ( Flags that get set on creating the next word )
variable wordComplete                                 ( whether code field has already been added to the current word )
variable mayLink                                      ( whether next word's JOIN property can be copied )
variable &lastWord                                    ( Locator of last word )
variable #INLINED                                     ( Number of already inlined references )
variable LAST_COMP                                    ( Last word compiled into the code )

--- Word Primitives ---

: LAST_COMP0! ( -- )  LAST_COMP 0! ;
: currentWord@ ( -- @w )  &lastWord @ ?dup unless  cr ." There is no current word!" terminate  then  &>a ;
: flags ( @word -- @word u )  dup w@ ;                ( Flags of word @word )
: flags@ ( @word -- u )  w@ ;                         ( Flags of word @word )
: flags+! ( %u @word -- )  wor! ;                     ( Set bit mask u as flags in word @word )
: resetFlags ( -- )  autoFlags 0! nextFlags 0! ;
: >CF ( @word -- a )  flags %INDIRECT and swap        ( Address of code field )
  2 + count + swap if  cell ->| @  else  2 ->| 2 +  then ;
: &CFA ( @voc @word -- &cfa )                         ( Reference to CFA of word @word in vocabulary @voc )
  >CF over §CODE @segaddr - §CODE swap >& ;
: &CF ( @voc @word -- &cf )                           ( Reference to code field of word @word in vocabulary @voc )
  flags swap >CF swap %INDIRECT and if  @  else  2+  then  §CODE vt& ;
: >next ( @word -- @word' )                           ( Skip to next word from word @word )
  dup 2 + count +                                     ( skip flags and name )
  swap flags@ %INDIRECT and if  cell ->| cell+  else  2 ->| dup w@ 2+ +  then    ( skip CF )
  2 ->| 2 + ;
: method? ( @word -- @word ? )  flags %CODETYPE 0- ;  ( whether @word is a method [regular, constructor or destructor] )
: regularMethod? ( @word -- @word ? )  flags %CODETYPE and %METHOD = ;
: constructor? ( @word -- @word ? )  flags %CODETYPE and %CONSTRUCTOR = ;
: destructor? ( @word -- @word ? )  flags %CODETYPE and %DESTRUCTOR = ;

--- Word Operations ---

: word$ ( @word -- $ )  2 + ;                         ( Name of word @word in vocabulary @voc )
: createWord ( a$ -- )  wordComplete 0!  #INLINED 0!  ( create word with name a$ )
  §CODE ↑tseg!  &t→| &lastWord !  nextFlags @ tw,  t$,  ↓tseg  autoFlags @ nextFlags ! ;
: _createIndirectAlias ( a$ @word -- )                 ( create alias for indirect word )
  flags nextFlags !                                     ( copy flags )
  §CODE tseg→| >r                                       ( save current length of code segment )
  drop &lastWord @ swap createWord                      ( create word )
  &>a dup >CF §CODE t&  §CODE ↑tseg! cell talign, t&,   ( copy CFA )
  cell talign,  4 + r> r− !uword tw,                    ( punch word length )
  ↓tseg ;
: createAlias ( a$ -- )                               ( create an alias of the last word with name a$ )
  currentWord@ flags %INDIRECT and if  _createIndirectAlias  exit  then ( handle indirect target separately )
  flags %INDIRECT or nextFlags !                        ( copy flags )
  §CODE tseg→| >r                                       ( save current length of code segment )
  drop &lastWord @ swap createWord                      ( create word )
  §CODE ↑tseg! &>a tvoc@ over &CFA  cell talign,  t&,   ( insert indirection to original CFA )
  cell talign,  8 + r> r− !uword tw,                    ( punch word length )
  ↓tseg  autoFlags @ nextFlags ! ;
: @w>& ( @voc @word -- &w )  §CODE vt& ;              ( word locator for word @word in vocabulary @voc )
: word, ( @voc @word -- )                             ( punch word @word in vocabulary @voc into target code segment )
  flags %JOIN and mayLink @ and if  %JOIN over flags+!  then  mayLink off  dup LAST_COMP !  &CF withVoc §CODE s&, ;

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
    %DEFINITION of  ."  • definition"  endof
    %METHOD of  ."  • method"  endof
    %DESTRUCTOR of  ."  • destructor"  endof
    %CONSTRUCTOR of  ."  • constructor"  endof
    endcase
  dup %INDIRECT and if  ."  • alias"  then
  dup %CONDITION and if  ."  • condition"  then
  dup %RELOCS and if  ."  • with relocations"  then
  drop ;
: alias. ( @word -- )                                 ( print information about compact alias )
  cr ." Alias @" dup hex.
  flags printFlags                                      ( print flags )
  2+ cr ." Name: "  dup qtype$                          ( print name )
  count + cell ->|
  dup @ cr ." Code: " dup 2- w@ bare-hexline            ( print code )
  cell+ 2 ->| cr ." Word Length: " w@ . ;               ( print word length )
: word. ( @word -- )                                  ( print information about word @word in vocabulary @voc )
  flags %INDIRECT and if  alias. exit  then
  cr ." Word @" dup hex.
  flags printFlags                                      ( print flags )
  2+ cr ." Name: "  dup qtype$  count +                 ( print name )
  2 ->| cr ." Code: " dup 2+ over w@ bare-hexline       ( print code )
  dup 2+ swap w@ + 2 ->| cr ." Word Length: " w@ . ;    ( print word length )

: isprefix? ( w$ -- ? )  count 0- swap 'a' '{' within and ;  ( Check if name w$ suggests it be a prefix )
: prefix? ( @word -- -? )  flags %PREFIX and swap 2 + isprefix? or ;  ( Check if word @word is a prefix in a composite )



=== Word Table ===

newHeap GlobalWords
newHeap GlobalHashEntries
newHeap GlobalNames

--- Dictionary Entry Structure ---

0000  dup constant DICT.WORD      ( Locator of word )
cell+ dup constant DICT.NAME      ( Offset of name in GlobalNames )
cell+ dup constant DICT.NEXT      ( Offset of next hash entry with same hash value )
cell+ constant DICTENTRY#         ( Size of a dictionary entry )

--- Holding ---

variable IntValue
variable CharValue
variable @StringValue
variable Vocabulary#Value
variable UseGlobalNames
create FloatValue  10 allot

variable Held
variable Held2
1 constant IntHeld
2 constant FloatHeld
3 constant CharHeld
4 constant StringHeld
5 constant ConditionHeld
6 constant BitTestHeld
7 constant VocabularyHeld

: holdInt ( n -- )  IntValue !  IntHeld Held ! ;
: holdFloat ( -- F: r -- )  FloatValue f!  FloatHeld Held ! ;
: holdChar ( uc -- )  CharValue !  CharHeld Held ! ;
: holdString ( $ -- )  @StringValue !  StringHeld Held ! ;
: holdCondition ( -- )  ConditionHeld Held ! ;
: holdBitTest ( -- )  BitTestHeld Held ! ;
: holdCondExpr ( -- )  ConditionHeld Held2 ! ;
: holdBTExpr ( -- )  BitTestHeld Held2 ! ;
: holdVocabulary ( -- )  VocabularyHeld Held ! ;

--- Dictionary Methods ---

: dict@ ( -- @dict )  GlobalWords !hactive haddr@ ;   ( Address of word table )
: dict@# ( -- @dict #dict )  GlobalWords !hactive |heap| ( Address and capacity of word table )
  ?dup unlessever  drop GlobalWords dup hcapa@ swap 0hallot  then ;
: $hash ( $ # -- u )                                  ( compute hash u of string $ with hash size #|#=2ⁿ )
  >x count 0 -rot 1+ 1 do  @c++ i * rot + swap  loop  drop  x> 1- and ;
(  0 8 0 do  over x@ 1- and xor swap 8 u>> swap  loop  nip x> drop ; )
: &word$ ( &w -- w$ )  &>a word$ ;                    ( Name w$ of word with referent &w )
: &hash ( &w # -- u )  swap &word$ swap $hash ;       ( compute hash u of word w with hash size # [:=2ⁿ] )
: useGlobalNames@ ( -- ? )  tvoc@ c" GlobalNames" !para@ 1+ c@ ;
: _!wck ( w$ &w -- &w )  dup &null = if               ( assert entry is not ambiguous [&null] )
  over ambiguous-word!  then  nip ;
: lookupWord ( w$ @d #d -- &w t | w$ f )              ( lookup word w$ in hashtable @d#d, returning its locator &w if found )
  cell/ >x  over x@ $hash cells+ @
  begin dup while  dup DICT.NAME + @ 2 pick $$= if  x> drop  DICT.WORD + @ _!wck true exit  then  DICT.NEXT + @  repeat  x> drop ;
: _set ( &w w$ @de -- )  DICT.WORD + dup @ &null = if  drop 2drop exit  then  ( already ambiguous: quit )
  2 pick >>@voc over @ >>@voc = if   nip ! exit  then                         ( same voc: overwrite )
  &null swap !  2drop ;                                                       ( different vocs: mark ambigous [&null] )
: +>word ( &w w$ @d #d -- )                           ( add word &w with name w$ to dictionary @d with capacity #d )
  ??" w0" 2 pick swap cell/ $hash ??" w1"
  cells dup $FF8 u> if  abort  then +  ( &w w$ @e )
  ??" w2" begin dup @ while  @ dup DICT.NAME + @ ( &w w$ @e w'$ ) 2 pick $$= if  ( &w w$ @e )  DICT.WORD + _set exit  then  DICT.NEXT +  repeat
  ( &w w$ @e )  DICTENTRY# GlobalHashEntries ??" w4" !hactive DICTENTRY# !hfree ??" w5" hallot drop  ( &w w$ @e @e2 ) ??" w6" dup rot ! ( &w w$ @e2 )
  ??" w7" tuck DICT.NAME + ! ( &w @e2 )  ??" w8" tuck DICT.WORD + !  DICT.NEXT + 0!  ??" w9" ;
: $+>word ( &w "w$" @d #d -- )                        ( add word &w with volatile name w$ to dictionary @d with capacity #d )
  ??" x0" GlobalNames !hactive >hend >r  rot GlobalNames h$,  r> -rot ??" x9" +>word ;
: findGlobalWord ( w$ -- &w t | w$ f )  dict@# lookupWord ;  ( lookup word in global word table, returning its locator if found )
: _segrange ( @voc seg# -- a # )  2dup segsize unlessever  2dup @segdescr PAGESIZE swap 0hallot 2drop  then  segrange ;
: findLocalWord ( $ @voc -- &w t | $ f )  §LWLT _segrange lookupWord ;  ( lookup word $ in vocabulary @voc )
: getTargetWord ( w$ -- &w )                          ( get the word or method locator for word or method w$, or fail )
  findGlobalWord unlessever  tvoc@ findLocalWord unlessever  cr ." Word not found: " qtype$ abort  then  then ;
: findWord ( $ -- &w t | $ f )                        ( lookup word with name $ in the search order, returning locator &w if found )
  Held @ VocabularyHeld = if  Held 0! Vocabulary#Value @0! findLocalWord exit  then  findGlobalWord ;
: addLocalWord ( &w w$ @voc -- )  ??" l0" dup >r §LWLT 2dup @segaddr -rot segcapacity r> voc. ??" l1" +>word ??" l9" ;
create GLOBAL_NAME  1024 allot
: >prefix ( @voc w$ -- $ )  GLOBAL_NAME swap $>$ swap vocabulary$ $+>$ ;
: >suffix ( @voc w$ -- $ )  GLOBAL_NAME rot vocabulary$ $>$ swap $+>$ ;
: _>voc ( &w w$ x -- @voc w$ x )  rot >>@voc -rot ;
: >globalname ( &w w$ -- $ )                          ( Global name of w$ with word &w )
  over &>a flags@ %PREFIX and over  count 0> swap c@ 'a' '{' within and or ??" >g" _>voc if  ??" >p" >prefix  else  ??" >s" >suffix  then ;
: addGlobalWord ( &w w$ -- )  2dup dict@#  $+>word  useGlobalNames@ if  2dup 2dup >globalname nip dict@# $+>word  then  2drop ;
: addWord ( &w -- )                                   ( add word &w to local and global word lookup tables )
  ??" a1" dup &>a word$ ( &w w$ )  2dup ??" a2" addGlobalWord  tvoc@ ??" a3" addLocalWord ;
: globalDict. ( -- )                                  ( prints the global dictionary )
  cr ." Global Dictionary: @"  dict@# over hex.  cell/ 0 do  dup
    begin dup @ while  @ dup DICT.NAME + @  cr  i 0 <# # # # # # #> type space type$ ." : "  dup DICT.WORD + @ hex. ."  -> " dup DICT.NEXT + @ hex.
      DICT.NEXT +  repeat  drop  cell+ loop  drop ;
: endword ( -- )  &lastWord @ addWord  -1 wordComplete ! globalDict. ; ( finalize current word definition )

---8<---
: lookupWord ( $ @ht -- &word t | $ f )               ( lookup word $ in hash table @ht )
  over hash ...
: findLocalWord ( $ @voc -- &word t | $ f )           ( lookup word $ in vocabulary @voc, returning its word address if found )
  §LWLT @segaddr lookupWord ;
: findGlobalWord ( $ -- &word t | $ f )               ( lookup word in global word lookup table; return its locator if found )
  GlobalWords @ lookupWord ;
: findWord ( $ -- @voc @word t | $ f )                ( find word $ in search order, returning its voc and word address )
  SearchOrder -heap cell/ 0 do
    cell- cr ." Looking up word in " dup @ "vocabulary".
    dup @ 2 pick over findLocalWord if  2swap 2drop true unloop exit  then  2drop  loop
  drop false ;
--->8---

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
16 constant MAX-BARE-COPY                             ( Maximum code-size to inline-copy, unless marked %INLINE )

: compExec ( a$ -- )  cr ." Compexec " dup qtype$  dup count @COMP-WORDS @ search-wordlist if  nip    ( execute compiler word a$ )
    depth 1- 0 max dup >B [ also Forcembler ] ADP+ execute B> ADP- [ previous ] exit  then
  cr ." Compiler word " qtype$ space ." not found!"  terminate ;

: code-range ( @word -- a # )                         ( Determine the code range w/o length, enter and exit code )
  >CF dup 2 - w@ ENTER# #-> EXIT# − TRIM @ #-> ;
: code# ( @word -- # )  code-range nip ;
: _r, ( ΔC @rel -- )  tuck @ swap  &+  t, RELOC.TARGET + @ t, ;    ( append relocation @rel, source-shifted by ΔC )
: inline-reloc, ( @word a -- )  §RELS ↑tseg!         ( Duplicate relocations of @word, biased to base a )
  over >CF ENTER# + −  swap code-range over + §CODE @tsegaddr tuck − -rot − swap  §RELS tsegrange RelocEntry# / 0 ?do
    dup RELOC.SOURCE + @ >>offset 2over within if  3 pick over _r,  then  RelocEntry# + loop  4 #drop
  ↓tseg ;
( TODO ?inline-join is machine-specific, so should be moved into machine-code vocabulary )
: ?inline-join ( @word -- @word )  LASTCONTRIB @ ?dup if  flags nip %LINK and if
  flags %JOIN and if  there 1- c@ $58 ( RAX POP ) = if  dup >CF ENTER# + c@ $50 ( RAX PUSH ) = if
    1 dup TRIM !  §CODE @tsegdescr hsize−!  then  then  then  then  then ;
: ?>joiner ( @word -- @word )  #INLINED @ unless  flags %JOIN and if  %JOIN currentWord@ flags+!  then  then ;
: ?>linker ( @word -- @word )  #INLINED @ unless  flags %LINK and if  %LINK currentWord@ flags+!  then  then ;
: inline-call, ( @voc @word -- )  cr ." Inline call: " &CFA dup hex. &CALL, ;
: inline-copy, ( @voc @word -- )  ?>linker  ?>joiner  ?inline-join  there >x  nip dup code-range ta#,  x> inline-reloc,  TRIM 0! ;

: int-indirect, ( n -- )  indirect-threading-not-supported! ;
: int-direct, ( n -- )  c" lit" findWord if  §CODE ↑tseg!  word, t,  ↓tseg  else  word-not-found!  then ;
: int-token, ( n -- )  token-threading-not-supported! ;
: int-inline, ( n -- )  dup -1 = if  drop c" lit-1"  else  dup nsize case
  0 of  drop c" lit0"  endof
  1 of  dup 0< if  c" lit1"  else  c" ulit1"  then  endof
  2 of  dup 0< if  c" lit2"  else  c" ulit2"  then  endof
  4 of  dup 0< if  c" lit4"  else  c" ulit4"  then  endof
  8 of  dup 0< if  c" lit8"  else  c" ulit8"  then  endof
  cr ." Invalid literal size: " . terminate  endcase  then  compExec ;
: float-indirect, ( -- F: r -- )  indirect-threading-not-supported! ;
: float-direct, ( -- F: r -- )  c" litf" findWord if  §CODE ↑tseg!  word, f,  ↓tseg  else  word-not-found! then ;
: float-token, ( -- F: r -- )  token-threading-not-supported! ;
: float-inline, ( -- F: r -- )  c" litf" compExec ;
: string-indirect, ( &$ -- )  indirect-threading-not-supported! ;
: string-direct, ( &$ -- )  c" lit$" findWord if  §CODE ↑tseg! word, t&,  ↓tseg  else  word-not-found! then ;
: string-token, ( &$ -- )  token-threading-not-supported! ;
: string-inline, ( &$ -- )  c" lit$" compExec ;
: word-indirect, ( @voc @word -- )  indirect-threading-not-supported! ;
: word-direct, ( @voc @word -- )  §CODE ↑tseg! word, t&,  ↓tseg ;
: word-token, ( @voc @word -- )  token-threading-not-supported! ;
: word-inline, ( @voc @word -- )
  dup >r flags %INLINE and over code# MAX-BARE-COPY < or if inline-copy, else inline-call, then
  #INLINED 1+! r> dup LASTCONTRIB ! LAST_COMP ! ;
: voc-indirect, ( @voc -- )  indirect-threading-not-supported! ;
: voc-direct, ( @voc -- )  c" vocabulary" findWord if  §CODE ↑tseg! word, t&,  ↓tseg  else  word-not-found! then ;
: voc-token, ( @voc -- )  token-threading-not-supported! ;
: voc-inline, ( @voc -- )  c" vocabulary" compExec ;

: resolveExxit ( ae a -- ae )  2dup - swap 4- d! ;  ( Resolves EXXIT at address a to actual exit at ae )
: resolveExxits ( -- )              ( Resolves all the unresolved EXXITs on the X stack; without reloc, as inside same method )
  §CODE tseg→|  YDEPTH 0 ?do  Y> resolveExxit  loop  drop ;

: invokeMethod ( @methref @word -- )
  ;
: invokeConstructor ( @methref @word -- ) ;
: invokeDestructor ( @methref @word -- ) ;



=== Output Control ===

create RESET  4 c, 27 c, '[' c, '0' c, 'm' c,
create RED  7 c, 27 c, '[' c, '0' c, ';' c, '9' c, '1' c, 'm' c,
create REDFLASH  15 c, 27 c, '[' c, '0' c, ';' c, '1' c, ';' c, '5' c, ';' c, '9' c, '1' c, ';' c, '1' c, '0' c, '3' c, 'm' c,
create YELLOW  7 c, 27 c, '[' c, '0' c, ';' c, '9' c, '3' c, 'm' c,
create GRAY  7 c, 27 c, '[' c, '0' c, ';' c, '9' c, '0' c, 'm' c,

: normal ( -- )  RESET type$ ;
: red ( -- )  RED type$ ;
: redflash ( -- )  REDFLASH type$ ;
: yellow ( -- )  YELLOW type$ ;
: gray ( -- )  GRAY type$ ;



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

: closeFile ( -- )
  cr ." Closing file " FILEID @ .
  FILEID dup @ ?dup if  space '(' emit @FILENAME @ type$ ')' emit
    close-file throw  then  0!        ( close current file and free associated buffers )
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
: eat. ( a # -- a' #' )  Period? off  dup if  over c@ '.' = if  Period? on  ->  then  then ;
: eatE ( a # -- a' #' )  Expo? off  dup if  over c@ dup 'e' = swap 'E' = or if  Expo? on  ->  then  then ;
: eatSign ( a # -- a' #' sgn )  dup if  over c@ case
    '+' of  ->  0  endof
    '-' of  -> -1  endof
    $2212 ( real minus − ) of  -> -1  endof
    0 swap  endcase  else  0  then ;
: eatQuote1 ( a # -- a' #' |>> a # f )
  2dup if  c@ $27 - if  false 2exit  then  ->  dup ( stb )  then drop ;  ( BLACK MAGIC: exit caller if not a quote )
: eatQuote2 ( a # -- a' #' )  Tfail on  2dup if  c@ $27 = if  Tfail off ->  then  dup ( stb ) then  drop ;
: eatDquote1 ( a # -- a' #' |>> a # f )
  2dup if  c@ '"' - if  false 2exit  then  ->  dup ( stb )  then drop ;  ( BLACK MAGIC: exit caller if not a double quote )
: eatDquote2 ( a # -- a' #' )  Tfail on  2dup if  c@ '"' = if  Tfail off ->  then  dup ( stb )  then  drop ;
: eatUC ( a # -- a' #' uc )  Tfail on  uc@>  dup 1+ if  Tfail off  then ;
: eatEsc ( a # -- a' #' c )  ->  2dup if c@ case
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
    '#' of  10 Tradix !  ->  endof
    '$' of  16 Tradix !  ->  endof
    '&' of   8 Tradix !  ->  endof
    '%' of   2 Tradix !  ->  endof
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
    c@ dup ',' = unless  >digit dup 0 Tradix @ within unless  drop exit  then
    Tfail off  IntValue# 1+!  IntValue @ Tradix @ * + IntValue ! else drop then  ->  repeat  drop ;
: eatDigits? ( a # -- a' #' )  IntValue 0!  IntValue# 0!
  begin  2dup  while
    c@ dup ',' = unless  >digit dup 0 Tradix @ within unless  drop exit  then
    IntValue# 1+!  IntValue @ Tradix @ * + IntValue ! else drop then  ->  repeat  drop ;
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
  over 1- findVocabulary ?dup if  -rot 2drop  §VOCA 0 >&  exit  then  drop
  cr ." Word «" type ." » not found! ⇒ quitting to FORTH." quit ;

: unvoc ( @voc -- )                                   ( Remove gforth vocabulary @voc from the search list )
  >x get-order dup 1 ?do  i pick x@ = if  i roll drop 1-  set-order  x> drop unloop exit  then  loop  x> drop ;



=== Compiler Clause Vocabularies ===

: pushHere ( -- ra )  tseg→| >CTRL ;
: resolveForward ( ctrl:ba -- )  tseg→| CTRL> tuck − swap 4- d! ;
: finishDef ( -- )
  LAST_COMP @ ?dup if  flags %LINK and if  %LINK currentWord@ flags+!  then  drop  then
  CTRLDEPTH if  unbalanced-definition!  then ;
: smashCondition ( -- cc )                            ( remove condition buildup from the code segment, to replace with ?JMP )
  §CODE @tsegdescr >hend 9 - c@ $F and $4000000 ( ← Forcembler Condition Code ) or
  10 §CODE @tsegdescr hsize−! ;
: smashBitTest ( -- cc )  3 §CODE @tsegdescr hsize−!  $4000003 ;  ( remove bit test buildup from the code segment )

--- Clause Vocabulary ---

vocabulary Clauses
also Clauses definitions  context @ @CLAUSES !

--- Int Clauses ---
: #+ ( x -- )  #PLUS, ;
: #- ( x -- )  #MINUS, ;
: #− ( x -- )  #MINUS, ;
: #r- ( x -- )  #RMINUS, ;
: #r− ( x -- )  #RMINUS, ;
: #u× ( u -- )  #UTIMES, ;
: #u* ( u -- )  #UTIMES, ;
: #× ( n -- )  #TIMES, ;
: #* ( u -- )  #TIMES, ;
: #! ( x -- )  #STORE, ;
: #+! ( x -- )  #QADD, ;
: #w+! ( x -- )  #WADD, ;
: #−! ( x -- )  #QSUB, ;
: #-! ( x -- )  #QSUB, ;
: #-> ( u -- )  #ADV, ;
: #pick ( u -- )  #PICK, ;
: #drop ( u -- )  #DROP, ;

: #= ( x -- )  #ISEQUAL,  holdCondExpr ;
: #< ( x -- )  #ISLESS,  holdCondExpr ;
: #> ( x -- )  #ISGREATER,  holdCondExpr ;

: #bit+ ( x -- x' )  #BSET, ;
: #bit− ( x -- x' )  #BCLR, ;
: #bit- ( x -- x' )  #BCLR,  holdBTExpr ;
: #bit× ( x -- x' )  #BCHG,  holdBTExpr ;
: #bit* ( x -- x' )  #BCHG,  holdBTExpr ;
: #bit? ( x -- ? )  #BTST,  holdBTExpr ;
: #bit?+ ( x # -- x' ? )  #BTSET,  holdBTExpr ;
: #bit?− ( x # -- x' ? )  #BTCLR,  holdBTExpr ;
: #bit?- ( x # -- x' ? )  #BTCLR,  holdBTExpr ;
: #bit?× ( x # -- x' ? )  #BTCHG,  holdBTExpr ;
: #bit?* ( x # -- x' ? )  #BTCHG,  holdBTExpr ;
: #bit?? ( x # -- x ? )  #BTTST,  holdBTExpr ;
: #bita?+ ( x # -- x' ? )  #ABTSET,  holdBTExpr ;
: #bita?− ( x # -- x' ? )  #ABTCLR,  holdBTExpr ;
: #bita?- ( x # -- x' ? )  #ABTCLR,  holdBTExpr ;
: #bita?× ( x # -- x' ? )  #ABTCHG,  holdBTExpr ;
: #bita?* ( x # -- x' ? )  #ABTCHG,  holdBTExpr ;

--- Char Clauses ---

--- Float Clauses ---

--- String Clauses ---

------
: $| ( ... $ -- $ )  $format ;
------

--- Condition Clauses ---
: ?if ( -- ctrl:ba )  smashCondition ?IF, ;
: ?ifever ( -- ctrl:ba )  smashCondition ?IFEVER, ;
: ?unless ( -- ctrl:ba )  smashCondition ?UNLESS, ;
: ?unlessever ( -- ctrl:ba )  smashCondition ?UNLESSEVER, ;
: ?until ( ctrl:ba -- )  smashCondition ?UNTIL, ;
: ?while ( ctrl:ba1 -- ctrl:ba2 ctrl:ba1 )  smashCondition ?WHILE, ;

--- Bit Test Clauses ---
: ^if ( -- ctrl:ba )  smashBitTest ?IF, ;
: ^ifever ( -- ctrl:ba )  smashBitTest ?IFEVER, ;
: ^unless ( -- ctrl:ba )  smashBitTest ?UNLESS, ;
: ^unlessever ( -- ctrl:ba )  smashBitTest ?UNLESSEVER, ;
: ^until ( ctrl:ba -- )  smashBitTest ?UNTIL, ;
: ^while ( ctrl:ba1 -- ctrl:ba2 ctrl:ba1 )  smashBitTest ?WHILE, ;

previous definitions



=== Compiler ===

--- Punching ---

: int, ( n -- )  code-model@ case
    INDIRECT-THREADED of  int-indirect,  endof
    DIRECT-THREADED of  int-direct,  endof
    TOKEN-THREADED of  int-token,  endof
    INLINED of  int-inline,  endof
    unknown-code-model!  endcase ;

: float, ( -- F: r -- )  §TEXT ↑tseg!  &t→| tf, ↓tseg  code-model@ case
    INDIRECT-THREADED of  float-indirect,  endof
    DIRECT-THREADED of  float-direct,  endof
    TOKEN-THREADED of  float-token,  endof
    INLINED of  float-inline,  endof
    unknown-code-model!  endcase ;

: char, ( uc -- )  code-model@ case
    INDIRECT-THREADED of  int-indirect,  endof
    DIRECT-THREADED of  int-direct,  endof
    TOKEN-THREADED of  int-token,  endof
    INLINED of  int-inline,  endof
    unknown-code-model!  endcase ;

: string, ( a$ -- )  §TEXT ↑tseg!  &t→| swap t$, ↓tseg  code-model@ case
    INDIRECT-THREADED of  string-indirect,  endof
    DIRECT-THREADED of  string-direct,  endof
    TOKEN-THREADED of  string-token,  endof
    INLINED of  string-inline,  endof
    unknown-code-model!  endcase ;
:noname ( a$ -- )  string, ; is str,

: vocabulary, ( @voc --)  code-model@ case
    INDIRECT-THREADED of  voc-indirect,  endof
    DIRECT-THREADED of  voc-direct,  endof
    TOKEN-THREADED of  voc-token,  endof
    INLINED of  voc-inline,  endof
    unknown-code-model!  endcase ;

: punchWord ( @voc @word -- )  code-model@ case
    INDIRECT-THREADED of  word-indirect,  endof
    DIRECT-THREADED of  word-direct,  endof
    TOKEN-THREADED of  word-token,  endof
    INLINED of  word-inline,  endof
    unknown-code-model!  endcase ;

: insertJmp ( cc -- )  §CODE ↑tseg!  9 @tdescr hsize−!  quit ;

: ?punchLiteral ( -- )  Held @0! case
      IntHeld of  IntValue @ int,  endof
      FloatHeld of  FloatValue f@ float,  endof
      CharHeld of  CharValue @ char,  endof
      StringHeld of  @StringValue @ string,  endof
      ConditionHeld of  endof
      BitTestHeld of  endof
      VocabularyHeld of  Vocabulary#Value @0! #voc@ vocabulary,  endof
      dup if  cr ." Invalid holding type: " dup . terminate  then  endcase ;

--- Loose Clauses ---

: ?buildClause ( $ -- $ f | t )  >x Held @ case
    0 of  x> false exit  endof
    IntHeld of  IntValue @ '#'  endof
    FloatHeld of  FloatValue f@ '%'  endof
    CharHeld of  CharValue @ '*'  endof
    StringHeld of  @StringValue @ '$'  endof
    ConditionHeld of  '?'  endof
    BitTestHeld of  '^'  endof
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
  §CODE ↑tseg!  1024 !tfree  2 talign,  0 tw,  t→| @codeAddr !  insertEnter  ↓tseg  mayLink on ;
: exitMethod ( -- )                                   ( close definition )
  resolveExxits  §CODE ↑tseg!  insertExit                ( punch EXIT into code )
  relocs dup @ swap 0! if  %RELOCS currentWord@ flags+!  then ( set relocations flag if relocations, and clear them )
  t→| @codeAddr @ tuck - swap 2 − w!                  ( update code length )
  2 talign,  ??" C"  t→| 2 + ??" c" currentWord@  ??" D" - tw,  ??" E"  ( punch the word length )
  ↓tseg  &lastWord @ addWord ;                        ( add word to word lookup tables )

--- Code for Classes ---

: pseg→|& ( -- )  §DATA &tseg→|  « PUSHPFA, » ;
: createTypeCheck ( -- )                             ( creates the !<class> word )
  MODULE-NAME $/ '!' c+>$ tvoc@ vocabulary$ $+>$ createWord  cr ." > class check"
  §CODE ↑tseg!  enterMethod
  &tvoc « LIT&, » c" !type" findWord if  punchWord  else  word-not-found$!  then
  ↓tseg  endword ;

create METHODNAME  256 allot
variable DYNAMIC#
variable constDepth
variable traceVoc

also Forcembler
: lvl>0  depth dup constDepth +! ADP+ ;
: lvl>1  depth 1- dup constDepth +! ADP+ ;
: lvl>2  depth 2- dup constDepth +! ADP+ ;
: lvl>3  depth 3 - dup constDepth +! ADP+ ;
: lvl>4  depth 4 - dup constDepth +! ADP+ ;
: lvl>5  depth 5 - dup constDepth +! ADP+ ;
: lvl>   constDepth @ ADP-  0 constDepth ! ;
: lvl++  -1 dup constDepth +! ADP+ ;
: lvl2+  -2 dup constDepth +! ADP+ ;
: lvl?   ." ADP=" ADP? . ;
previous

: createDynamic ( addr$ -- )                          ( create adress in instance data space )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or!  createWord  cr ." > dynamic address"
  §CODE ↑tseg!  lvl>0  enterMethod  tvoc@ c" Size" !para@ 1+ @ « #PLUS, »
  ↓tseg  endword  lvl> ;
: createDynamicVal ( # &tp|&null val$ -- )            ( create dynamic value val$ of size # and type &tp )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! dup >x  createWord  ( create basic val )  cr ." > dynamic base val"
  drop ( until we store the type somewhere )
  §CODE ↑tseg!  lvl>0  enterMethod  tvoc@ c" Size" !para@ 1+ dup >x @ dup DYNAMIC# ! « #PLUS, »  dup abs x> +!
  ↓tseg  endword  lvl>
  METHODNAME x> $>$ '@' c+>$  createWord              ( create getter )  cr ." > getter"
  §CODE ↑tseg!  lvl>0  enterMethod  DYNAMIC# @ swap lvl++ « ##FETCH, »  ↓tseg  endword  lvl> ;
: createDynamicVar ( # &tp|0 var$ -- )                  ( create dynamic variable var$ of size # and type &tp )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! dup >x  createWord  ( create basic var )  cr ." > dynamic base var"
  drop ( until we store the type somewhere )
  §CODE ↑tseg!  lvl>0  enterMethod  tvoc@ c" Size" !para@ 1+ dup >x @ dup DYNAMIC# ! « #PLUS, »  dup abs x> +!
  ↓tseg  endword  lvl>
  METHODNAME x@ $>$ '@' c+>$  createWord                ( create getter )  cr ." > getter"
  §CODE ↑tseg!  lvl>0  enterMethod  DYNAMIC# @ over « ##FETCH, »  ↓tseg  endword  lvl>
  METHODNAME x> $>$ '!' c+>$  createWord                ( create setter )  cr ." > setter"
  §CODE ↑tseg!  lvl>0  enterMethod  DYNAMIC# @ swap lvl++ « ##STORE, »  ↓tseg  endword  lvl> ;
: allotDynamic ( # -- )  cr ." Dynamic allot " dup .  tvoc@ c" Size" !para@ 1+ +! ; ( allot # bytes of any value in instance data space )
: 0allotDynamic ( # -- )  cr ." Dynamic 0allot " dup .  tvoc@ c" Size" !para@ 1+ +! ; ( allot # bytes of value 0 in instance data space )
: createStatic ( addr$ -- )                           ( create adress in instance data space )
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or!  createWord  cr ." > static address"
  §CODE ↑tseg!  lvl>0  enterMethod  pseg→|&  ↓tseg  endword  lvl> ;
: createStaticVal ( x # &tp|0 val$ -- )  >x           ( create static value val$ with value x, size # and type &tp )
  METHODNAME x@ $>$ '@' c+>$  createWord              ( create getter )  cr ." > getter"
  §CODE ↑tseg!  lvl>0  enterMethod  0 swap lvl>1 pseg→|& « ##FETCH, »  ↓tseg  endword  lvl>
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! x>  createWord  §CODE ↑tseg!  ( create base val )  cr ." > static base val"
  drop  lvl>1  enterMethod  lvl>  ↓tseg  endword ;
: createStaticVar ( # &tp|0 var$ -- )  >x  drop       ( create static variable val$ with size # and type &tp )
  METHODNAME x@ $>$ '@' c+>$  createWord                ( create getter )  cr ." > getter"
  §CODE ↑tseg!  lvl>0  enterMethod  0 over lvl>1 pseg→|& lvl2+ « ##FETCH, »  ↓tseg  endword  lvl>
  METHODNAME x@ $>$ '!' c+>$  createWord                ( create setter )  cr ." > setter"
  §CODE ↑tseg!  lvl>0  enterMethod  0 over lvl>1 pseg→|& lvl2+ « ##STORE, »  ↓tseg  endword  lvl>
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or! x>  createWord  §CODE ↑tseg!  ( create base val )  cr ." > static base var"
  lvl>1  0 swap #pf,  enterMethod  lvl>  ↓tseg  endword ;
: createStaticObject ( &tp obj$ -- )                  ( create direct static object obj$ of type &tp )
  over &>a c" Size" !para@ 1+ @ >x                      ( = size of object instance )
  cr ." Object size: " x@ .
  %VISIBILITY nextFlags andn!  %PRIVATE nextFlags or!  createWord
  §DATA ↑tseg!  dup t&,  ↓tseg
  §CODE ↑tseg!  lvl>1  enterMethod  « PUSHPFA, »  lvl>  ↓tseg  endword
  §DATA ↑tseg!  x> tallot, ↓tseg ;
: allotStatic ( # -- )                                ( allot # bytes of any value in vocabulary data space )
  cr ." Static allot " dup .  §DATA @tsegdescr hallot 2drop ;
: 0allotStatic ( # -- )                               ( allot # bytes of value 0 in vocabulary data space )
  cr ." Static 0allot " dup .  §DATA @tsegdescr 0hallot 2drop ;

--- Main ---

create bit$ ," bit"
: compile ( $ -- )  cr ." Compiling " dup qtype$
  ?buildClause if  exit  then
  ?punchLiteral
  findWord  tempSearchVoc 0! if
    flags %CONDITION and if
      dup 2+ bit$ $$> if  cr ." Holding bit test." holdBitTest  else  cr ." Holding condition." holdCondition  then  then
    punchWord  exit  then
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
  over 1- findVocabulary  ?dup if  -rot 2drop Vocabulary#Value !  holdVocabulary exit  then  drop
  word-not-found! ;
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
: readName ( -- a$ )  readWord dup c@ unless  cr ." End of input: definition terminated!" exit  then ;
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

: vocabulary; ( -- )                                  ( end vocabulary definition: ship vocabulary )
  VOC-WORDS @ unvoc  shipVocabulary  target>  %STATIC autoFlags andn! ;
: extends ( >name -- )                                ( load entire vocabulary into current vocabulary )
  readName findVocabulary ?dup unless  vocabulary-not-found!  then
  dup voctype@ ?dup if  0 invalid-vocabulary-type!  then  insert-voc ;
: val ( &type|# >name -- )                            ( create an unmodifiable field member of type &type or size # )
  dup 2 cells u≤ if  ( size )  &null  else  ( type )  cell swap  then  readName  cr ." val " dup qtype$  createStaticVal ;
: var ( &type|# >name -- )                            ( create a modifiable field member of type &type or size # )
  cr ." vocabulary var "
  dup 2 cells ≤ if  ( size )  &null  else  ( type )  cell swap  then  readName  cr ." var " dup qtype$  createStaticVar ;
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
  createTypeCheck CLASS-WORDS @ unvoc  shipVocabulary  target> ;
: val ( &type|# >name -- )                            ( create an unmodifiable field member of type &type or size # )
  dup 2 cells u≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." val " dup qtype$
  nextFlags @ %STATIC and if  createStaticVal  else  createDynamicVal  then ;
: var ( &type|# >name -- )                            ( create a modifiable field member of type &type or size # )
  dup 2 cells u≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." var " dup qtype$
  nextFlags @ %STATIC and if  createStaticVar  else  createDynamicVar  then ;
: implements ( >name -- )                             ( add a base interface )
  readName  loadModule  extend ;
: extends ( >name -- )                                ( add a base class )
  readName  loadModule  extend ;
: create ( >name -- )                                 ( create a name referring to the parameter segment )
  readName  nextFlags @ %STATIC and if  createStatic  else  createDynamic  then ;
: allot ( # -- )                                      ( reserve # bytes of any value in the parameter segment )
  nextFlags @ %STATIC and if  allotStatic  else  allotDynamic  then ;
: 0allot ( # -- )                                     ( reserve # bytes of value 0 in the parameter segment )
  nextFlags @ %STATIC and if  0allotStatic  else  0allotDynamic  then ;
: size ( -- u ) tvoc@ c" Size" !para@ holdInt ;

previous definitions



=== Interface Vocabulary ===

variable INTERFACE-WORDS

vocabulary InterfaceWords
also InterfaceWords definitions  context @ INTERFACE-WORDS !

: interface; ( -- )                                   ( end interface definition: ship interface )
  createTypeCheck INTERFACE-WORDS @ unvoc  shipVocabulary  target> ;

previous definitions



=== Structure Vocabulary ===

variable STRUCT-WORDS

vocabulary StructWords
also StructWords definitions  context @ STRUCT-WORDS !

: structure; ( -- )                                   ( end structure definition: ship structure )
  createTypeCheck STRUCT-WORDS @ unvoc  shipVocabulary  target> ;
: val ( &type|# >name -- )                            ( create an unmodifiable field member of type &type or size # )
  dup 2 cells u≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." val " dup qtype$
  createDynamicVal ;
: var ( &type|# >name -- )                            ( create a modifiable field member of type &type or size # )
  cr ." structure var "
  dup 2 cells u≤ if  ( it's a size )  &null  else  ( it's a type )  cell swap  then  readName  cr ." var " dup qtype$
  createDynamicVar ;

previous definitions



=== Enum Vocabulary ===

variable ENUM-WORDS

vocabulary EnumWords
also EnumWords definitions  context @ ENUM-WORDS !

: enum; ( -- )                                        ( end enum definition: ship enum )
  shipVocabulary  ENUM-WORDS @ unvoc  baseClass @ ?dup if  unvoc  then  target> ;
: symbol ( >name -- )                                 ( add a symbol to the enum )
  readName  cr ." constant " dup qtype$  createWord  §CODE ↑tseg!
  tvoc@ c" Next" !para@ 1+ dup @ lvl>1  enterMethod  int,  lvl>  ↓tseg  endword
  1+!  tvoc@ c" Count" !para@ 1+ 1+! ;

previous definitions



=== Enumset Vocabulary ===

variable ENUMSET-WORDS

vocabulary EnumsetWords
also EnumsetWords definitions  context @ ENUMSET-WORDS !

: enumset; ( -- )                                     ( end enum definition: ship enum )
  shipVocabulary  ENUMSET-WORDS @ unvoc  baseClass @ ?dup if  unvoc  then  target> ;
: symbol ( >name -- )                                 ( add a symbol to the enumset )
  readName  cr ." enumset constant " dup qtype$  createWord  §CODE ↑tseg!
  tvoc@ c" Next" !para@ 1+ dup @ lvl>1  enterMethod  int,  lvl>  ↓tseg  endword
  1+!  tvoc@ c" Count" !para@ 1+ 1+! ;
: count ( -- # )  tvoc@ c" Count" !para@ 1+ @ ;       ( number of symbols in the enumset )
: next ( -- # )  tvoc@ c" Next" !para@ 1+ @ ;         ( index of the next symbol in the enumset )  alias size

previous definitions



=== Compiler Vocabulary ===

vocabulary compiler
also compiler definitions  context @ @COMP-WORDS !

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
: invoke ( &methref -- )  cr ." > invoke: method reference " dup hex.
  dup &>a flags %CODETYPE case
    %CONSTRUCTOR of  invokeConstructor  of
    %METHOD of  invokeMethod  of
    %DESTRUCTOR of  invokeDestructor  of
    cr ." Don't invoke normal definition through 'invoke''!" abort  endcase
  LAST_COMP0! ;
: my ( -- a )  « THIS, »  LAST_COMP0! ;  alias me  alias I'm  alias this  alias self   ( push the current instance )
: vocabulary ( @voc -- )  cr ." Adding " dup "vocabulary". ."  to search list."  dup addSearchVoc tempSearchVoc ! ;
: size ( -- u ) tvoc@ c" Size" !para@ holdInt ;
: raise ( -- )  « EXPUSH, »  LAST_COMP0! ;
: exitif ( -- )  « EXITIF, »  LAST_COMP0! ;
: exitunless ( -- )  « EXITUNLESS, »  LAST_COMP0! ;
: begin ( -- ctrl:ba )  « BEGIN, »  LAST_COMP0! ;
: again ( ctrl:ba -- )  « AGAIN, »  LAST_COMP0! ;
: until ( ctrl:ba -- )  « UNTIL, »  LAST_COMP0! ;
: while ( ctrl:ba1 -- ctrl:ba2 ctrl:ba1 )  « WHILE, »  LAST_COMP0! ;
: repeat ( ctrl:ba2 ctrl:ba1 -- )  « REPEAT, »  LAST_COMP0! ;
: do ( -- ctrl:ba1 ctrl:ba2 )  « DO, »  LAST_COMP0! ;
: udo ( -- ctrl:ba1 ctrl:ba2 )  « UDO, »  LAST_COMP0! ;
: loop ( ctrl:ba1 ctrl:ba2 -- )  « LOOP, »  LAST_COMP0! ;
: +loop ( ctrl:ba1 ctrl:ba2 -- )  « PLUS_LOOP, »  LAST_COMP0! ;
: −loop ( ctrl:ba1 ctrl:ba2 -- )  « MINUS_LOOP, »  LAST_COMP0! ;  alias -loop
: uloop ( ctrl:ba1 ctrl:ba2 -- )  « ULOOP, »  LAST_COMP0! ;
: +uloop ( ctrl:ba1 ctrl:ba2 -- )  « PLUS_ULOOP, »  LAST_COMP0! ;
: −uloop ( ctrl:ba1 ctrl:ba2 -- )  « MINUS_ULOOP, »  LAST_COMP0! ;  alias -uloop
: if ( -- ctrl:ba )  « IF, »  LAST_COMP0! ;
: ifever ( -- ctrl:ba )  « IFEVER, »  LAST_COMP0! ;
: unless ( -- ctrl:ba )  « UNLESS, »  LAST_COMP0! ;
: unlessever ( -- ctrl:ba )  « UNLESSEVER, »  LAST_COMP0! ;
: ?dupif ( -- ctrl:ba )  « CONDUPIF, »  LAST_COMP0! ;
: ?dupifever ( -- ctrl:ba )  « CONDUPIFEVER, »  LAST_COMP0! ;
: else ( ctrl:ba1 -- ctrl:ba2 )  « ELSE, »  LAST_COMP0! ;
: then ( ctrl:ba -- )  « THEN, »  LAST_COMP0! ;
: ?? ( >tag -- )  readName cr 27 emit ." [1;106m" type$ .sh 27 emit ." [0m" ;
: ( ( >...rpar -- )  c" )" comment-bracket ;          \ skips a parenthesis-comment
: ;  finishDef  endword  LASTCONTRIB 0!  LAST_COMP0!  doInterpret ;     \ finish definition

previous definitions



=== Additional Forcembler Words ===

vocabulary ForcemblerWords
also ForcemblerWords  definitions  context @ @FORCEMBLER-WORDS !

: SAVE, ( -- )  « PUSH, »  %JOIN currentWord@ flags+! ;    ( Insert DUP and mark word as joiner )
: RESTORE, ( -- )  « DROP, »  %LINK currentWord@ flags+! ; ( Insert DROP and mark word as linker )
: ; ( -- )  ↓tseg  endword  FORC 0!  %INLINE currentWord@ flags+! ;    ( Finish code word )

previous definitions



=== Interpreter Vocabulary ===

: pervious previous ;
: als0 also ;
variable codecomp

variable currentVoc
variable testErrors

vocabulary Interpreter
also Interpreter definitions  context @ @INTERPRETER !

1 constant U1
2 constant U2
4 constant U4
8 constant U8
16 constant U16
-1 constant N1
-2 constant N2
-4 constant N4
-8 constant N8
-16 constant N16
10 constant Real

: vocabulary ( >name -- )                             ( create a vocabulary with name from input stream )
  readName  cr ." vocabulary " dup qtype$  createVocabulary
  §PARA ↑tseg!  c" Package" t$, currentPackage t$,  c" GlobalNames" t$, 1 tc, -1 tc,  ↓tseg ;
: package ( >name -- )                                ( adds a package specification to the vocabulary )
  currentPackage readName  cr ." package " dup qtype$ $>$ drop ;
: also ( >name -- )                                   ( push vocabulary with name from input stream onto search order )
  readName  findVocabulary ?dup if  addSearchVoc exit  then
  cr ." Vocabulary «" type$ ." » not found!" terminate ;
: definitions ( -- )  primary tvoc! ;                 ( set top vocabulary of search order to target vocabulary )
: previous ( -- )  previousOrder ;                    ( pop top vocabulary from search order )
: inline ( -- )  %INLINE currentWord@ flags+! ;       ( make last word inline )
: join ( -- )  %JOIN currentWord@ flags+! ;           ( Mark current word as joiner )
: link ( -- )  %LINK currentWord@ flags+! ;           ( Mark current word as linker )
: private ( -- )  currentWord@ flags %VISIBILITY andn  %PRIVATE or swap w! ;  ( Mark current word as private )
: public ( -- )  currentWord@ flags %VISIBILITY andn  %PUBLIC or swap w! ;  ( Mark current word as public )
: protected ( -- )  currentWord@ flags %VISIBILITY andn  %PROTECTED or swap w! ;  ( Mark current word as public )
: package-private ( -- )  currentWord@ flags %VISIBILITY andn  %PACKAGE or swap w! ;  ( Mark current word as package-private )
: condition ( -- )  %CONDITION currentWord@ flags+! ; ( Mark current word as a condition )
: fallible ( -- )  %FALLIBLE currentWord@ flags+! ;   ( Mark current word as fallible )
: target ( -- @voc|0 )  tvoc@ ;                       ( Current target vocabulary )
: constant ( x >name -- )                             ( create a constant with value x )
  readName  cr ." constant " dup qtype$  createWord  §CODE ↑tseg!
  lvl>1  enterMethod  int,  lvl>  ↓tseg  endword ;
: variable ( >name -- )                               ( create a variable with initial value 0 )
  readName  cr ." variable " dup qtype$  createWord  §CODE ↑tseg!
  lvl>0  enterMethod  pseg→|&  §DATA ↑tseg!  0 t,  ↓tseg  lvl>  ↓tseg  endword ;
: =variable ( x >name -- )                            ( create a variable with initial value x )
  readName  cr ." =variable " dup qtype$  createWord  §CODE ↑tseg!
  lvl>1  enterMethod  pseg→|&  §DATA ↑tseg!  t,  ↓tseg  lvl>  ↓tseg  endword ;
: import ( >path -- )  readName                       ( import the file with the specified path or name )
  cr ." Importing " dup qtype$  loadModule ;
: requires ( >name -- )  readName loadModule depend ; ( import the specified file and make it a dependency of the current voc )
: s" ( >string" -- a # )  '"' readString count ;      ( read a dquote-delimited string from the input stream )
: quit ( -- )  closeAll  quit ;                       ( quit the REPL )
: ****** ( >... ****** )  c" ******" comment-bracket ;    ( skip a 6*-comment )
: ------ ( >... ------ )  c" ------" comment-bracket ;    ( skip a 6-dash-comment )
: --- ( >... --- )  c" ---" comment-bracket ;         ( skip a 3-dash-comment )
: === ( >... === )  c" ===" comment-bracket ;         ( skip a 3=-comment )
: see ( >name -- )  readName  findWord if             ( print word )
  word.  else  cr ." Word «" type$ ." » not found!"  then ;
: vocabulary: ( >name -- )  vocabulary  0 >voctype    ( create vocabulary and set up for definitions )
  lastVoc @ addSearchVoc  definitions  als0 VocabularyWords  resetFlags %STATIC %PUBLIC or dup autoFlags or! nextFlags or! ;
: class: ( >name -- )  vocabulary  1 >voctype         ( create class and set up for its body )
  lastVoc @ addSearchVoc  definitions  als0 ClassWords  §PARA ↑tseg!  c" Size" t$, cell tc, 0 t, ↓tseg
  resetFlags %PRIVATE dup autoFlags or! nextFlags or! ;
: interface: ( >name -- )  vocabulary  2 >voctype     ( create interface and set up for its body )
  resetFlags %PUBLIC or dup autoFlags or! nextFlags or!
  lastVoc @ addSearchVoc  definitions  als0 InterfaceWords ;
: enum: ( >name -- )  vocabulary  3 >voctype          ( create byte enum and set up for its body )
  resetFlags %PRIVATE or dup autoFlags or! nextFlags or!
  §PARA ↑tseg!  c" Next" t$, cell tc, 0 t,  c" Count" t$, cell tc, 0 t,  ↓tseg
  c" /force/internal/enumbase1" loadModule  extend
  loadedModule @ baseClass !  lastVoc @ addSearchVoc  definitions  als0 EnumWords ;
: enumset: ( # >name -- )  vocabulary  4 >voctype     ( create enum set of size # and set up for its body )
  resetFlags %PRIVATE or dup autoFlags or! nextFlags or!
  §PARA ↑tseg!  c" Next" t$, cell tc, 0 t,  c" Count" t$, cell tc, 0 t,  ↓tseg
  MODULE-NAME c" /force/internal/enumsetbase" $>$ swap abs u+>$ loadModule  extend
  loadedModule @ baseClass !  lastVoc @ addSearchVoc  definitions  als0 EnumsetWords ;
: structure: ( >name -- )  vocabulary  5 >voctype     ( create structure and set up for its body )
  resetFlags %PRIVATE or dup autoFlags or! nextFlags or!
  lastVoc @ addSearchVoc  definitions  als0 StructWords  §PARA ↑tseg!  c" Size" t$, cell tc, 0 t, ↓tseg ;
: code: ( >name -- )                                  ( create machine code word )
  cr ." Entering definition with depth " depth . ."  (should be 0)"
  readName  cr ." code: " dup type$  createWord  enterMethod  -1 FORC !  §CODE ↑tseg! ;
: alias ( >name -- )                                  ( create an alias for the last word with the given name )
  readname  cr ." alias " dup qtype$  createAlias ;
: public: ( -- )  %VISIBILITY autoFlags andn!  %PUBLIC autoFlags or! ;        ( set default visibility to public )
: private: ( -- )  %VISIBILITY autoFlags andn!  %PRIVATE autoFlags or! ;      ( set default visibility to private )
: protected: ( -- )  %VISIBILITY autoFlags andn!  %PROTECTED autoFlags or! ;  ( set default visibility to protected )
: package: ( -- )  %VISIBILITY autoFlags andn!  %PACKAGE autoFlags or! ;      ( set default visibility to package )
: NoGlobalNames ( -- )  tvoc@ c" GlobalNames" !para@ 1+ c0! ;
: traceIt ( -- )  loadedModule @ cr ." >>>>>>> Tracing " dup "vocabulary". traceVoc ! ;
: trace ( -- )  cr ." >>>>>>>>> trace <<<<<<<" traceVoc @ voc. ;
: print" ( >..." -- )  '"' readString qtype$ ;
: ?? ( >tag -- )  readName cr 27 emit ." [1;106m" type$ .sh 27 emit ." [0m" ;
: init: ( -- )                                        ( creates the module entry point )
  cr ." init: " c" _main_" %PRIVATE nextFlags or!  createWord  doCompile  enterMethod ;
( Testing: )
: tests: ( -- )  testErrors 0!                                    ( start tests )
  cr cr ." Performing tests."
  depth ?dup if  cr red ." Depth is " . ." before tests start -> fix this!" normal  testErrors 1+!  then ;
: tests; ( -- )                                                   ( end tests )
  depth ?dup if  cr red ." Depth is " . ." after tests finished -> fix this!" normal  testErrors 1+!  then
  testErrors @ ?dup if cr redflash . ." error(s) discovered during the tests!" normal terminate else cr ." Tests successful." then ;
: !voc ( >name -- )                                   ( check presence of vocabulary )
  readName  cr ." Check presence of vocabulary " dup qtype$ space
  findVocabulary ?dup unless  redflash ." failed: fatal!" normal drop quit  else  ." successful: @" hex.  then ;
: voc: ( >name -- )                                   ( make vocabulary current )
  readName  cr ." Make vocabulary " dup qtype$ ."  current ... "
  findVocabulary ?dup unless  redflash ." failed: fatal!" normal quit  else  dup currentVoc ! targetVoc ! ." successful."  then ;
: !def ( >name -- )                                   ( check presence of definition in current vocabulary )
  readName  cr ." Check presence of definition " dup qtype$ space
  currentVoc @ findLocalWord if
    ." successful: @" dup hex. ."  (Code#" currentVoc @ §CODE @segaddr - hex. ')' emit  else
    yellow ." failed." normal drop  testErrors 1+!  then ;
: !code ( >name >... >";" -- )                        ( validate code )
  readName  cr ." Verify code of word " dup qtype$ space
  currentVoc @ findLocalWord unless  yellow ." : word not found!" normal  testErrors 1+!  else  dup word.
    cr ." Code: "
    currentVoc @ swap &CFA &>a  begin  readName dup c@ over c" ;" $$= invert and while
      dup c" <<" $$= if  drop -1 codecomp !  else  dup c" >>" $$= if  drop 0 codecomp !  else
      codecomp @ if  gray  then  $>hex over c@ over = unless  codecomp @ unless  red  then  then  hex2. normal  1+  space
      then  then  repeat  drop  then ;
: !is ( >name >... >";" -- )
  readName cr ." Verify flags of word " dup qtype$ ."  (red: wrong, yellow: missing): "
  currentVoc @ findLocalWord unless  yellow ." : word not found!" normal  testErrors 1+!  else
    flags  begin  readName dup c@ over c" ;" $$= invert and while
      tuck isFlag unless  red  testErrors 1+!  then  swap type$  normal space  repeat  drop  then ;
: !isonly ( >name >... >";" -- )
  readName cr ." Verify flags of word " dup qtype$ ."  (red: wrong, yellow: missing): "
  currentVoc @ findLocalWord unless  yellow ." : word not found!" normal else
    flags $70000 or  begin  readName dup c@ over c" ;" $$= invert and while
      tuck isFlag unless  red  testErrors 1+!  then  swap type$  normal space  repeat
  drop yellow
  dup $10000 and if  dup %EXECTYPE and case
    0 of  ." code-threaded "  endof
    1 of  ." direct-threaded "  endof
    2 of  ." indirect-threaded "  endof
    3 of  ." token-threaded "  endof  endcase  testErrors 1+!  then
  dup $20000 and if  dup %VISIBILITY and case
    %PRIVATE of  ." private "  endof
    %PROTECTED of  ." protected "  endof
    %PACKAGE of  ." package-private "  endof
    %PUBLIC of  ." public "  endof  endcase  testErrors 1+!  then
  dup $40000 and if  dup %CODETYPE and case
    %DEFINITION of  ." definition "  endof
    %METHOD of  ." method "  endof
    %CONSTRUCTOR of  ." constructor "  endof
    %DESTRUCTOR of  ." destructor "  endof  endcase  testErrors 1+!  then
  dup %RELOCS and if  ." relocs "  testErrors 1+!  then
  dup %MAIN and if  ." main "   testErrors 1+!  then
  dup %STATIC and if  ." static "   testErrors 1+!  then
  dup %INDIRECT and if  ." indirect "   testErrors 1+!  then
  dup %ABSTRACT and if  ." abstract "   testErrors 1+!  then
  dup %CONDITION and if  ." condition "   testErrors 1+!  then
  dup %RELOCS and if  ." inline "   testErrors 1+!  then
  dup %JOIN and if  ." joiner "   testErrors 1+!  then
  dup %LINK and if  ." linker "   testErrors 1+!  then
  dup %FALLIBLE and if  ." fallible "   testErrors 1+!  then
  dup %PREFIX and if  ." prefix "   testErrors 1+!  then
  drop  normal  then  drop ;

: ( ( >...rpar -- )  c" )" comment-bracket ;          \ skips a parenthesis-comment
: : \ >name -- \                                      \ create a code word with name from input stream \
  cr ." Entering definition with depth " depth . ."  (should be 0)"
  readName  cr ." : " dup type$  createWord  doCompile  enterMethod ;

pervious definitions

------
when calling a method, distinguish:
- object is invocation class or a subclass -> straightforward
- object is an implementation of invocation class -> extract virtual table part
------

REPL
