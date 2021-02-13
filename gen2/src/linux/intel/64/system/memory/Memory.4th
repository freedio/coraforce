( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Memory Module for FORCE-linux 4.19.0-5-amd64 ******

package linux/intel/64/system/memory
import /force/intel/64/core/ForthBase
import /linux/intel/64/system/SystemMacro

------
• Memory page size is 4096 bytes — if this assumption has to be changed, the how module is obsolete.
• All ranges "x up to y" include x and exclude y (should actually go without saying)
• There are 3 types of memory pages:
  - "Small Pages" hold homogenous entries of size 1 up to 511.
  - "Large Pages" hold mixed size entries of size 511 up to 4080.
  - "Huge Pages" hold entries of size 4080 and bigger (limited only by virtual memory size).
• All pages start with a general header, followed by an individual header due to their page type.  The first data entry immediately
  follows the header.
• General page header:
  cell      NEXT                                      ( Pointer to the next page of the same type )
  byte      TYPE                                      ( Page type )
  byte      FLAGS                                     ( Page status flags )
• Small page header extension (inclusinf entries):
  word      CAPACITY                                  ( Total number of slots per page )
  word      #FREE                                     ( Number of free slots )
  word      USED#                                     ( Size of the allocation table in bytes )
  bit[n]    USED                                      ( Allocation table, 1 bit per slot )
  entry[n]  ENTRIES                                   ( The entries of size TYPE )
• Large page header extension (including entries):
  byte      #RECORDS                                  ( Number of records on the page )
  record[n] RECORDS                                   ( The records; each record is a length+status word followed by the entry )
• Huge page header extension:
  byte      #PAGES                                    ( Number of consecutive pages occupied by the entry )
  qword     #ENTRY                                    ( Size of the entry in bytes )
• FLAGS:
  bit 0:    TYPEXT                                    ( 0: Page type is 0..256, 1: Page type is 256..512 )
  bit 1:
  bit 2:
  bit 3:
  bit 4:
  bit 5:
  bit 6:
  bit 7:    FULL                                      ( 1: Page is full )
• A page array is a memory page containing a list of page numbers for entries of the size equal to the page index --- except for 0
  which is for large entries, and page 511, which is for huge entries.  So the 4ₜₕ page number is for entries of size 4, the 100ₜₕ
  page number for entries of size 100.  The page array is initialized to all zeros, which means that there aren't any pages yet.
• There are two page arrays: one for anonymous chunks of memory, called ChunkSpace, and one for objects, called ObjectSpace.  This
  makes garbage collection easier.
• The page directory is a linked list of  pages below the program break that have been freed.  It points at the first page, which
  in turn points at the next page through the first <cell> bytes of the page itself, and contains the number of pages in the next
  <cell> bytes.  Contiguous areas are continually merged.  The last page contains a link of 0.  If the page directory itself is 0,
  then there are no free pages below the program break.  The last block of pages just below the program break is never entered into
  the page directory; instead, the program break is reduced.
------

vocabulary: Memory

  cell var InitialBreak                                 ( Initial program break )
  cell var CurrentBreak                                 ( Current program break = top memory )
  PageArray object ObjectSpace                          ( The object space page array )
  PageArray object ChunkSpace                           ( The chunk space page array )
  PageDirectory object PageDir                          ( The page directory )
  Page# ± constant -Page#                               ( Mask of a memory page address. )
  12 constant Page%                                     ( Shift for page related operations, linked with Page#. )

private:
  : @page ( #p -- @p )  Page% u<< ;                     ( Address @p of page number #p )
  : #page ( @p -- #p )  Page% u>> ;                     ( Number #p of page at address @p )
  : reduceRange ( a # -- a' )  over cell+ −!  dup cell+ @ @page + ;   ( reduce freed page range a by # pages; return removed range )
  : reallocRange ( a -- a )                             ( remove page range a from pagedir; return its address )
    PageDir@ over =? if  over @ swap ! exit  then  begin dup while  2dup @ = if  over @ swap ! exit  then  @ repeat drop
    ABORT MemoryReallocationError new raise ;  fallible
  : reallocate ( a # -- a )                             ( realloc # pages of freed page range a¹ )
    ( ¹ if a contains more than # pages, remove last # and allocate, otherwise reuse whole page range )
    debug? if  cr 2dup over cell+ @ swap 3 "Reallocating %d pages from page array of %d pages at %016X"| debug.  then
    over cell+ @ over u> if  reduceRange  else  drop reallocRange  then
    debug? if  dup 1 ": @%016X."| debug.  then ;
  : allocNewPage ( -- a )                               ( allocate a single page after the current break; return its address a )
    debug? if  cr " Allocating new page" debug.  then
    CurrentBreak@ dup Page# + pgmbreak unless >errmsg 1 "Fatal error while setting the program break: %s!"|abort then  CurrentBreak!
    debug? if  cr CurrentBreak@ 1 ": @016X."| debug.  then ;
  : _unlinkPage ( @p a -- )                             ( unlink page @p from page array slot @a )
    begin 2dup @ @page ≠ while  @ @page 0=?until  2drop exit  then  swap Successor@ swap !
public:
  : endOf ( -- a )  -1 SYS-BRK, ;                       ( Address of first byte after allocated memory = end of memory )
  : extend ( u -- a )  endOf + SYS-BRK, ;               ( extend memory by u and return new end of memory )
  : shrink ( u -- a )  negate extend ;                  ( shrink memory by u and return new end of memory )

  init: ( @initstr -- @initstr )
    0 pgmbreak unless  >errmsg 1 "Fatal error while initializing Linux memory: %s!"abort  then  dup InitialBreak !  CurrentBreak !
    ChunkSpace setup  ObjectSpace setup  PageDirectory setup ;

vocabulary;
